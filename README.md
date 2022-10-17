# Лабораторна робота #1

## Завдання

Реалізувати лексичний та синтаксичний аналізатор арифметичного виразу з використанням будь-якої мови програмування. Необхідно, щоб аналізатор перевіряв такі типи помилок:
 - помилки на початку арифметичного виразу ( наприклад, вираз не може починатись із закритої дужки, алгебраїчних операцій * та /);
 - помилки, пов’язані з неправильним написанням імен змінних,  констант та при необхідності функцій;
 - помилки у кінці виразу (наприклад, вираз не може закінчуватись будь-якою алгебраїчною операцією);
 - помилки в середині виразу (подвійні операції, відсутність операцій перед або між дужками, операції* або / після відкритої дужки тощо);
 - помилки, пов’язані з використанням дужок ( нерівна кількість відкритих та закритих дужок, неправильний порядок дужок, пусті дужки).
Синтаксичний аналізатор потрібно реалізувати за допомогою кінцевого автомату.

# Синтаксис

Токени
```
letter = 'a' | ... | 'z' | 'A' | ... | 'Z'
digit = '0' | ... | '9'
letdig = digit | letter
**id** = letter letdig*
**numconst** = digit+ ['.' digit+]
whiteSpace = ' ' | '\t'
```

Граматика
```
expr = mulExpr (sumOp mulExpr)*
sumOp = '+' | '-'
mulExpr = unaryExpr (mulOp unaryExpr)*
mulOp = '*' | '/'
unaryExpr = unaryOp unaryExpr | factor
unaryOp = '-' | '+'
factor = '(' expr ')' | call | id | numconst
call = id '(' ')' | id '(' args ')' 
args = expr (',' expr)*
```