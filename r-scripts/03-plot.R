# Simple scatter plot in base R
x <- 1:10
y <- x^2

plot(x, y, type = "b", col = "blue", pch = 19,
     main = "Simple Quadratic Plot",
     xlab = "x", ylab = "y")
