#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

// deletion starting from list's head
char* delete(LinkedList *ll) {
  LinkedListNode *lln;
  char* data;

  if (ll->head == NULL) {
    return NULL;
  } else {
    lln = ll->head;
    data = (char*)malloc(sizeof(char) * strlen(lln->data));
    strcpy(data, lln->data);

    if (ll->head == ll->tail) {
      ll->head = NULL;
      ll->tail = NULL;
    } else {
      ll->head = ll->head->next;
      ll->head->prev = NULL;
    }

    free(lln);
    return data;
  }
}

char* reverse_delete(LinkedList *ll) {
  LinkedListNode *lln;
  char* data;

  if (ll->tail == NULL) {
    return NULL;
  } else {
    lln = ll->tail;
    data = (char*)malloc(sizeof(char) * strlen(lln->data));
    strcpy(data, lln->data);

    if (ll->tail == ll->head) {
      ll->tail = NULL;
      ll->head = NULL;
    } else {
      ll->tail = ll->tail->prev;
      ll->tail->next = NULL;
    }

    free(lln);
    return data;
  }
}