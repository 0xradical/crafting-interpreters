#include <stdlib.h>
#include "unity.h"
#include "ll.h"

void setUp(void) {
    // set stuff up here
}

void tearDown(void) {
    // clean stuff up here
}

void test(void) {
  LinkedList ll = {NULL, NULL};
  char* data;
  TEST_ASSERT_EQUAL(0, length(ll));
  append(&ll, "Thiago");
  print(ll);
  TEST_ASSERT_EQUAL(1, length(ll));
  append(&ll, "Mario");
  print(ll);
  TEST_ASSERT_EQUAL(2, length(ll));
  data = delete(&ll);
  print(ll);
  TEST_ASSERT_EQUAL(1, length(ll));
  TEST_ASSERT_EQUAL_STRING(data, "Thiago");
  prepend(&ll, "Bruno");
  print(ll);
  TEST_ASSERT_EQUAL(2, length(ll));
  free(data);
  data = reverse_delete(&ll);
  print(ll);
  TEST_ASSERT_EQUAL(1, length(ll));
  TEST_ASSERT_EQUAL_STRING(data, "Mario");
  free(data);
}

int main(void) {
  UNITY_BEGIN();
  RUN_TEST(test);
  return UNITY_END();
}