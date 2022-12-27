// RUN: %check_clang_tidy %s cert-exp45-c %t

// https://wiki.sei.cmu.edu/confluence/display/c/EXP45-C.+Do+not+perform+assignments+in+selection+statements

void foo() {}
int boo(bool i) {}

void assignmentsInSelectionExpression() {
    int A = 0, B = 0, C = 1, X = 2;
    // triggers check 
    if (A = B) {
    // CHECK-MESSAGES: :[[@LINE-1]]:11: warning: assignment is not allowed inside if statement [cert-exp45-c]

    // do something 
    }

    while (A = B) {
    // CHECK-MESSAGES: :[[@LINE-1]]:14: warning: assignment is not allowed inside while statement [cert-exp45-c]
    
    // do something 
    }


    do {

    } while (C = B);
    // CHECK-MESSAGES: :[[@LINE-1]]:16: warning: assignment is not allowed inside do while statement [cert-exp45-c]

    // comma assignment violation case
    do { /* ... */ } while (foo(), A = B);
    // CHECK-MESSAGES: :[[@LINE-1]]:38: warning: assignment is not allowed inside do while statement [cert-exp45-c]
    
    // multiple commas check
    do { /* ... */ } while (foo(), foo(), A = B);
    // CHECK-MESSAGES: :[[@LINE-1]]:45: warning: assignment is not allowed inside do while statement [cert-exp45-c]

    for (int i = 0; i = A; i++) {
    // CHECK-MESSAGES: :[[@LINE-1]]:23: warning: assignment is not allowed inside for statement [cert-exp45-c]
    }

    // EX-2 CASES
    int W;
    bool Flag = false;
    if ((X = W) && Flag) { /* ... */ }
    // CHECK-MESSAGES: :[[@LINE-1]]:12: warning: assignment is not allowed inside and statement [cert-exp45-c]

    while (X = 3 && (B = 3) && (X = 3) != 0 || (W = 6) != 0 || true) {}   
    // CHECK-MESSAGES: :[[@LINE-1]]:14: warning: assignment is not allowed inside while statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:24: warning: assignment is not allowed inside and statement [cert-exp45-c]

    while (X = 3 && (B = 3) && (X = 3) || (W = 6) != 0 || true) {}
    // CHECK-MESSAGES: :[[@LINE-1]]:14: warning: assignment is not allowed inside while statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:24: warning: assignment is not allowed inside and statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-3]]:35: warning: assignment is not allowed inside and statement [cert-exp45-c]

    bool Bol = (X = 3) && true;
    // CHECK-MESSAGES: :[[@LINE-1]]:19: warning: assignment is not allowed inside and statement [cert-exp45-c]

    Bol = (X = 3) || false;
    // CHECK-MESSAGES: :[[@LINE-1]]:14: warning: assignment is not allowed inside or statement [cert-exp45-c]
   
    Bol = (X = 3) or false;
    // CHECK-MESSAGES: :[[@LINE-1]]:14: warning: assignment is not allowed inside or statement [cert-exp45-c]

    // Ternary expressions
    if (A = B ? 6 : A = 4) {}
    // CHECK-MESSAGES: :[[@LINE-1]]:11: warning: assignment is not allowed inside if statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:23: warning: assignment is not allowed inside if statement [cert-exp45-c]

    // 2. 2nd Operand case
    if (W ? A = 5 : 8) {}
    // CHECK-MESSAGES: :[[@LINE-1]]:15: warning: assignment is not allowed inside if statement [cert-exp45-c]

    // 4. Inside conditional expressions
    while (W ? 6 : A = 4) {}
    // CHECK-MESSAGES: :[[@LINE-1]]:22: warning: assignment is not allowed inside while statement [cert-exp45-c]

    if (X = W = A ? 4 : 6) {}
    // CHECK-MESSAGES: :[[@LINE-1]]:11: warning: assignment is not allowed inside if statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:15: warning: assignment is not allowed inside if statement [cert-exp45-c]


    while ((X = 4) ? (X = 5) && B : (W = 8)) {
    // CHECK-MESSAGES: :[[@LINE-1]]:15: warning: assignment is not allowed inside ternary condition statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:25: warning: assignment is not allowed inside and statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-3]]:40: warning: assignment is not allowed inside while statement [cert-exp45-c
    }

    do {

    } while (X = 1, X ? B : W = 4 ? A = 5 : 5 );
    // CHECK-MESSAGES: :[[@LINE-1]]:31: warning: assignment is not allowed inside do while statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:39: warning: assignment is not allowed inside do while statement [cert-exp45-c]

    // nested ternary
    while (X ? true ? X = B : false ? B : W = X : W) {}
    // CHECK-MESSAGES: :[[@LINE-1]]:25: warning: assignment is not allowed inside while statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:45: warning: assignment is not allowed inside while statement [cert-exp45-c]

    bool Y = (true ? X = C : C = A) ? B = A : B = A;
    // CHECK-MESSAGES: :[[@LINE-1]]:24: warning: assignment is not allowed inside ternary condition statement [cert-exp45-c]
    // CHECK-MESSAGES: :[[@LINE-2]]:32: warning: assignment is not allowed inside ternary condition statement [cert-exp45-c]

    int L = (A, B = A, X = W) ? 4 : 5; 
    // CHECK-MESSAGES: :[[@LINE-1]]:26: warning: assignment is not allowed inside ternary condition statement [cert-exp45-c]

    int XY = (A = B) && C ?: 5;
    // CHECK-MESSAGES: :[[@LINE-1]]:17: warning: assignment is not allowed inside and statement [cert-exp45-c]
}

void assignmentsInSelectionEdgeCases() {
    int A = 1, B = 4, C;


    // Compliant Solution (Intentional Assignment)
    do { /* ... */ } while (foo(), (A = B) != 0);

    // Compliant Solution (Intentional Assignment)
    if ((A = B) != 0) {
        /* ... */
    }

    // Compliant Solution (Intentional Assignment)
    for (int i = 0; i == A ; i = A, i++) {
        /* do something */
    }

    // Compliant Solution (Ternary outside of Selection Statement)
    A = B ? 6 : A = 4;

    // Compliant Solution (Ternary outside of Selection Statement)
    A = B ? B= 1 : A = 4;

    // Compliant Solution (Ternary outside of Selection Statement)
    A = B ? B = 3 : 4;


    // True-Positive found from the running checker on FFmpeg
    if (boo(A = B)) {}

    A = boo(A = B) ? 12 : 5; 
}

void assignmentsOutsideSelection() {
    const int A = 0;
    int B = 0;
    if (A) {
        // do something 
    }

    // Compliant Solution (Unintentional Assignment)
    if (A == B) {
        /* ... */
    }


    // Compliant Solution (Intentional Assignment)
    if ((B = A)) {
        // do something 
    }

    // Compliant Solution (Intentional Assignment)
    if ((B = A) != B) {
        // do something 
    }

    // Compliant Solution (Assignment)
    do { /* ... */ } while (foo(), A == B); 

    int x, y;
    float p, q;
    do { /* ... */ } while (x = y, p == q);


    // Compliant Solution For Loop (FuncCall)
    for (; x; foo(), x = y) { /* ... */ }

    int arr[10];
    // Compliant Solution If (Array expression)
    if (arr[x = y]) {}
    if (arr[x, x = y])

    // Compiant Solution (Top parenthesis)
    while (((x = 4) ? (y = 5) && B : (p = 8))) {}
    while ((x, x= y)) {}
    while ((x, y = p ? y : p)) {}

    while ((x = y = p)) {}

    while (x == (p == ( x ? p : q) )) {}


    // Compliant solution
    while ('\t' == x || ' ' == x || '\n' == x) {}

    if (((x = p) != 0) && x) {}
};
