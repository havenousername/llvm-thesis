.. title:: clang-tidy - cert-assignments-in-selection

cert-assignments-in-selection
=============================

For more information, see:
http://wiki.sei.cmu.edu/confluence/display/c/EXP45-C.+Do+not+perform+assignments+in+selection+statements

Assignments (e.g. ``a = b``) in predicates or queries can be
problematic. In many cases, the user might have intended to write
``a == b`` instead. Several existing **compiler warnings**,
e.g. ``-Wparentheses`` can warn for *SOME* cases of the issue, e.g. the
following is warned about:

.. code:: cpp

   if (a = b)
     foo();

::

   <source>:4:11: warning: using the result of an assignment as a condition without parentheses [-Wparentheses]
       if (a = b)
           ~~^~~
   <source>:4:11: note: place parentheses around the assignment to silence this warning
       if (a = b)
             ^
           (    )
   <source>:4:11: note: use '==' to turn this assignment into an equality comparison
       if (a = b)
             ^
             ==

Detect more complex cases
=========================

More complex cases, such as

.. code:: cpp

   do {
     foo();
   } while (a = b, b = c);

are not warned about, however.

Detect false negatives not detected by ``-Wparentheses``
========================================================

If you observe the first example, it says that wrapping the assignment
in an additional set of parentheses will silence the warning, i.e.

.. code:: cpp

   if ( (a = b) ) foo();

is considered as intentional assignment by the user.

Problem arises when such parenthesised expressions are combined with
logical operators, though:

.. code:: cpp

   if ( (a = b) && coin ) foo();

In this case, ``-Wparentheses`` no longer fires, because the assignment
is wrapped. When ignoring the side effects, this is equivalent to the
value check of ``b && coin``, however, the problem is that the user
still most likely could have typod the expression, and wanted to check
the equality and the flag being true at the same time by wanting to type
``(a == b) && flag`` (without the wrapping, the ``&&`` would have higher
priority, and ``a == b && flag`` would implicitly parenthesise as
``a == (b && flag)``). Such mistakes are often introduced when during
refactoring efforts.

For this case, the recommendation is to make the “booleanness check”
explicit, i.e. write

.. code:: cpp

   if ( ((a = b) != 0) && flag ) foo();
   //    ^~~~~~~ an intended assignment
   //   ^        ~~~~~ making it explicit that we are checking the "bool-ness" of the return value

=========================
TODO: Change parts of explanation after code is done 