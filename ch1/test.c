#include "unity.h"
#include "ll.h"

void setUp(void) {
    // set stuff up here
}

void tearDown(void) {
    // clean stuff up here
}

void test_length(void) {
  LinkedList ll = {NULL, NULL};
  TEST_ASSERT_EQUAL(0, length(ll));
  append(&ll, "Thiago");
  print(ll);
  TEST_ASSERT_EQUAL(1, length(ll));
  append(&ll, "Mario");
  print(ll);
  TEST_ASSERT_EQUAL(2, length(ll));
}

int main(void) {
  UNITY_BEGIN();
  RUN_TEST(test_length);
  return UNITY_END();
}