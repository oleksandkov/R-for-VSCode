# Create and inspect a simple data frame
students <- data.frame(
  name = c("Alice", "Bob", "Charlie"),
  score = c(90, 85, 92)
)

print(students)
print(summary(students$score))
