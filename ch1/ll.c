#include <stdio.h>
#include <stdlib.h>
#include "ll.h"

void prepend(LinkedList* ll, char* string) {
  LinkedListNode *head = ll->head;
  LinkedListNode *tail = ll->tail;
  LinkedListNode *node = (LinkedListNode*)malloc(sizeof(LinkedListNode));
  node->data = string;

  if (head == NULL) {
    ll->head = node;
    ll->tail = node;
  } else {
    ll->head->prev = node;
    node->next = ll->head;
    ll->head = node;
  }
}

void append(LinkedList* ll, char* string) {
  LinkedListNode *head = ll->head;
  LinkedListNode *tail = ll->tail;
  LinkedListNode *node = (LinkedListNode*)malloc(sizeof(LinkedListNode));
  node->data = string;

  if (tail == NULL) {
    ll->head = node;
    ll->tail = node;
  } else {
    ll->tail->next = node;
    node->prev = ll->tail;
    ll->tail = node;
  }
}

void _print(LinkedListNode *lln) {
   if (lln == NULL) {
    printf("NULL\n");
  } else {
    if(lln->prev == NULL) {
      printf("NULL <- %s -> ", lln->data);
    } else {
      printf("<- %s -> ", lln->data);
    }
    _print(lln->next);
  }
}

void print(LinkedList ll) {
  _print(ll.head);
}

int _length(LinkedListNode* lln) {
  if (lln == NULL) {
    return 0;
  } else {
    return 1 + _length(lln->next);
  }
}

int length(LinkedList ll) {
  return _length(ll.head);
}

// int main() {
//   // printf() displays the string inside quotation
//   LinkedList ll = { NULL, NULL };
//   char *s = "Thiago";
//   printf("%i\n", length(ll.head));
//   prepend(&ll, "Bruno");
//   prepend(&ll, "Thiago");
//   append(&ll, "Mario");
//   print(ll.head);
//   // char *t = s;
//   printf("Hello, World!\n");
//   printf("%s\n", ll.head->data);
//   printf("%i\n", length(ll.head));
//   return 0;
// }