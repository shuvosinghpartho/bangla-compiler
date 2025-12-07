%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* Updated Node structure to support Arrays */
struct Node {
    char *name;
    int value;          // For normal variables
    int *arrValues;     // For arrays
    int size;           // Array size
    int isArray;        // Flag: 0 = variable, 1 = array
    struct Node *next;
};

struct Node *head = NULL;

/* Helper: Find a node by name */
struct Node* find_node(char *name) {
    struct Node *ptr = head;
    while (ptr != NULL) {
        if (strcmp(ptr->name, name) == 0) return ptr;
        ptr = ptr->next;
    }
    return NULL;
}

/* 1. Assign Scalar Variable (e.g., a = 10) */
void assign_var(char *name, int val) {
    struct Node *ptr = find_node(name);
    if (ptr) {
        // If it was an array, we technically overwrite it as a scalar here
        if (ptr->isArray) {
            free(ptr->arrValues);
            ptr->arrValues = NULL;
            ptr->isArray = 0;
        }
        ptr->value = val;
        return;
    }
    
    // Create new scalar node
    struct Node *newNode = (struct Node *)malloc(sizeof(struct Node));
    newNode->name = strdup(name);
    newNode->value = val;
    newNode->isArray = 0;
    newNode->arrValues = NULL;
    newNode->next = head;
    head = newNode;
}

/* 2. Declare Array (e.g., ধরি a[10]) */
void declare_array(char *name, int size) {
    struct Node *ptr = find_node(name);
    if (ptr) {
        printf("Error: Variable or Array '%s' already exists.\n", name);
        return;
    }
    
    struct Node *newNode = (struct Node *)malloc(sizeof(struct Node));
    newNode->name = strdup(name);
    newNode->isArray = 1;
    newNode->size = size;
    newNode->arrValues = (int *)malloc(size * sizeof(int));
    
    // Initialize array with 0s
    for(int i = 0; i < size; i++) {
        newNode->arrValues[i] = 0;
    }
    
    newNode->next = head;
    head = newNode;
}

/* 3. Assign Array Index (e.g., a[0] = 50) */
void assign_array_val(char *name, int index, int val) {
    struct Node *ptr = find_node(name);
    if (!ptr) {
        printf("Error: Array '%s' not declared.\n", name);
        return;
    }
    if (!ptr->isArray) {
        printf("Error: '%s' is not an array.\n", name);
        return;
    }
    if (index < 0 || index >= ptr->size) {
        printf("Error: Index %d out of bounds for array '%s' (Size: %d).\n", index, name, ptr->size);
        return;
    }
    
    ptr->arrValues[index] = val;
}

/* 4. Get Scalar Value */
int get_val(char *name) {
    struct Node *ptr = find_node(name);
    if (!ptr) {
        // printf("Warning: Variable '%s' not found, returning 0.\n", name);
        return 0;
    }
    if (ptr->isArray) {
        printf("Error: Cannot use array '%s' without index.\n", name);
        return 0;
    }
    return ptr->value;
}

/* 5. Get Array Value */
int get_array_val(char *name, int index) {
    struct Node *ptr = find_node(name);
    if (!ptr) {
        printf("Error: Array '%s' not found.\n", name);
        return 0;
    }
    if (!ptr->isArray) {
        printf("Error: '%s' is not an array.\n", name);
        return 0;
    }
    if (index < 0 || index >= ptr->size) {
        printf("Error: Index %d out of bounds for array '%s'.\n", index, name);
        return 0;
    }
    return ptr->arrValues[index];
}

int yylex();
void yyerror(const char *s);
%}

%union {
    int ival;
    char *sval;
}

%token <ival> NUMBER
%token <sval> IDENTIFIER
%token K_INT K_PRINT K_FOR K_WHILE K_IF K_ELSE

/* Precedence to solve "dangling else" conflict */
%nonassoc K_IFX
%nonassoc K_ELSE

%type <ival> expr

%left '<' '>'
%left '+' '-'
%left '*' '/'

%%

program:
    | program statement
    ;

assignment:
      /* Scalar: ধরি x = 10 */
      K_INT IDENTIFIER '=' expr             { assign_var($2, $4); }
    | IDENTIFIER '=' expr                   { assign_var($1, $3); }

      /* Array Declaration: ধরি arr[10] */
    | K_INT IDENTIFIER '[' NUMBER ']'       { declare_array($2, $4); }

      /* Array Assignment: arr[0] = 50 */
    | IDENTIFIER '[' expr ']' '=' expr      { assign_array_val($1, $3, $6); }
    ;

statement:
      assignment ';'
    | K_PRINT expr ';'                      { printf("ফলাফল: %d\n", $2); }
    
    /* Loops */
    | K_FOR '(' assignment ';' expr ';' assignment ')' '{' program '}' 
      { printf("For Loop parsed.\n"); }
      
    | K_WHILE '(' expr ')' '{' program '}'
      { printf("While Loop parsed.\n"); }

    /* IF Statement */
    | K_IF '(' expr ')' '{' program '}' %prec K_IFX
      {
          if ($3) {
              printf("Condition is TRUE.\n");
          } else {
              printf("Condition is FALSE.\n");
          }
      }

    /* IF-ELSE Statement */
    | K_IF '(' expr ')' '{' program '}' K_ELSE '{' program '}'
      {
          if ($3) {
               printf("Condition is TRUE (Else block skipped).\n");
          } else {
               printf("Condition is FALSE (Else block executed).\n");
          }
      }
    ;

expr:
      NUMBER                { $$ = $1; }
    | IDENTIFIER            { $$ = get_val($1); }
    
    /* Array Access: arr[0] */
    | IDENTIFIER '[' expr ']' { $$ = get_array_val($1, $3); }
    
    | expr '+' expr         { $$ = $1 + $3; }
    | expr '-' expr         { $$ = $1 - $3; }
    | expr '*' expr         { $$ = $1 * $3; }
    | expr '/' expr         { $$ = $1 / $3; }
    | expr '<' expr         { $$ = $1 < $3; }
    | expr '>' expr         { $$ = $1 > $3; }
    ;

%%

void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}

int yywrap() {
    return 1;
}

int main() {
    printf("Bangla Compiler Ready .\n");
    yyparse();
    return 0;
}