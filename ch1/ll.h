typedef struct LinkedListNode LinkedListNode;
typedef struct LinkedList LinkedList;

struct LinkedListNode {
  LinkedListNode *prev;
  LinkedListNode *next;
  char *data;
};

struct LinkedList {
  LinkedListNode *head;
  LinkedListNode *tail;
};

int length(LinkedList);
void prepend(LinkedList*, char*);
void append(LinkedList*, char*);
void print(LinkedList);