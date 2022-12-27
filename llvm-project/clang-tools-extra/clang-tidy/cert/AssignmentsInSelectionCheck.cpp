//===--- AssignmentsInSelectionCheck.cpp - clang-tidy ---------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "AssignmentsInSelectionCheck.h"
#include "clang/AST/ASTContext.h"
#include "clang/AST/ASTTypeTraits.h"
#include "clang/AST/Expr.h"
#include "clang/AST/Stmt.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/ASTMatchers/ASTMatchersInternal.h"
#include "clang/ASTMatchers/Dynamic/Registry.h"
#include "clang/Basic/SourceLocation.h"
#include "llvm/ADT/Optional.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/ADT/StringRef.h"
#include "llvm/Support/Casting.h"
#include <algorithm>
#include <cstddef>
#include <variant>

using namespace clang::ast_matchers;

namespace clang {
namespace tidy {
namespace cert {

class AssignmentsInSelectionCheck::OutputControl {
private:
  llvm::SmallVector<SourceLocation, 10> WarningLocations;
  enum OperatorType { IF, WHILE, DO_WHILE, FOR, TERNARY, AND, OR, UNKOWN };

public:
  bool hasWarning(SourceLocation Location) {
    return std::find(WarningLocations.begin(), WarningLocations.end(),
                     Location) != WarningLocations.end();
  }

  void addWarning(SourceLocation Location) {
    return WarningLocations.push_back(Location);
  }

  OperatorType getOperatorType(const Stmt *Operator) const {
    switch (Operator->getStmtClass()) {
    case clang::Stmt::WhileStmtClass:
      return WHILE;
    case clang::Stmt::ForStmtClass:
      return FOR;
    case clang::Stmt::DoStmtClass:
      return DO_WHILE;
    case clang::Stmt::IfStmtClass:
      return IF;
    case clang::Stmt::ConditionalOperatorClass:
      return TERNARY;
    case clang::Stmt::BinaryConditionalOperatorClass:
      return TERNARY;
    case clang::Stmt::BinaryOperatorClass: {
      const llvm::StringRef Str =
          reinterpret_cast<const BinaryOperator *>(Operator)->getOpcodeStr();
      if (Str.equals("&&")) {
        return AND;
      }

      if (Str.equals("||")) {
        return OR;
      }
      llvm_unreachable("Unexpected unknown statement class");
    }
    default:
      llvm_unreachable("Unexpected unknown statement class");
    }
  }
};

AssignmentsInSelectionCheck::AssignmentsInSelectionCheck(
    StringRef Name, ClangTidyContext *Context)
    : ClangTidyCheck(Name, Context), Control(new OutputControl()) {}

namespace {
ast_matchers::internal::Matcher<clang::Stmt>
conditionalForEachMatcher(decltype(forEach(stmt())) Stmt) {
  return stmt(
      anyOf(binaryConditionalOperator(Stmt), conditionalOperator(Stmt)));
}

ast_matchers::internal::Matcher<clang::Stmt>
conditionalHasConditionMatcher(decltype(hasCondition(stmt())) Stmt) {
  return stmt(
      anyOf(binaryConditionalOperator(Stmt), conditionalOperator(Stmt)));
}
} // namespace

void AssignmentsInSelectionCheck::registerMatchers(MatchFinder *Finder) {
  // binary matchers
  const auto AssignmentMatcher =
      binaryOperator(isAssignmentOperator(),
                     unless(anyOf(hasAncestor(callExpr()),
                                  hasAncestor(arraySubscriptExpr()))))
          .bind("assignment");
  const auto CommaMatcher =
      binaryOperator(hasOperatorName(","), hasRHS(AssignmentMatcher))
          .bind("comma");
  const auto AndOrMatcher = binaryOperator(
      hasAnyOperatorName("&&", "||"),
      forEach(implicitCastExpr(hasDescendant(AssignmentMatcher))),
      // nested and | or expression. like ((x = y && b))
      unless(hasAncestor(parenExpr())));

  const auto MatchAssignment =
      anyOf(AssignmentMatcher, CommaMatcher,
            implicitCastExpr(anyOf(has(AssignmentMatcher), has(CommaMatcher))));
  const auto ForEachConditional = conditionalForEachMatcher(forEach(stmt(
      anyOf(MatchAssignment, has(parenExpr(has(stmt(MatchAssignment))))))));
  // Conditions MatchAssignment
  // Match conditions inside selection statements (expept ? operator)
  const auto HasConditionMatcher = hasCondition(allOf(
      forEachDescendant(
          stmt(anyOf(implicitCastExpr(MatchAssignment), ForEachConditional))),
      unless(implicitCastExpr(
          anyOf(has(parenExpr()), has(implicitCastExpr(has(parenExpr()))))))));

  // For the cases when (=) ? anything : anything.
  const auto HasConditionCondionalMatcher = hasCondition(
      allOf(forEachDescendant(stmt(anyOf(
                implicitCastExpr(has(parenExpr(has(stmt(MatchAssignment))))),
                ForEachConditional))),
            unless(implicitCastExpr(
                has(implicitCastExpr(has(parenExpr(has(parenExpr()))))))),
            unless(hasAncestor(parenExpr()))));

  Finder->addMatcher(
      stmt(anyOf(whileStmt(HasConditionMatcher), ifStmt(HasConditionMatcher),
                 doStmt(HasConditionMatcher), forStmt(HasConditionMatcher),
                 conditionalHasConditionMatcher(HasConditionCondionalMatcher),
                 AndOrMatcher))
          .bind("assignment-not-allowed-expression"),
      this);
}

void AssignmentsInSelectionCheck::check(
    const MatchFinder::MatchResult &Result) {
  const auto *MatchedExpressionAssignment =
      Result.Nodes.getNodeAs<Stmt>("assignment-not-allowed-expression");

  if (MatchedExpressionAssignment) {
    const auto OperatorType =
        Control->getOperatorType(MatchedExpressionAssignment);
    const auto *Assignment =
        Result.Nodes.getNodeAs<BinaryOperator>("assignment");

    if (Control->hasWarning(Assignment->getOperatorLoc())) {
      return;
    }

    Control->addWarning(Assignment->getOperatorLoc());
    diag(Assignment->getOperatorLoc(),
         "assignment is not allowed inside %select{if|while|do "
         "while|for|ternary condition|and|or|unknown}0 statement")
        << OperatorType;
  }
}

} // namespace cert
} // namespace tidy
} // namespace clang
