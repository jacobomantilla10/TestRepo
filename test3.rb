
def fibonacci(n, memo = {})
  return n if n <= 1
  return memo[n] if memo.key?(n)

  memo[n] = fibonacci(n - 1, memo) + fibonacci(n - 2, memo)
  memo[n]
end

# Test the function
puts fibonacci(0)   # 0
puts fibonacci(1)   # 1
puts fibonacci(5)   # 5
puts fibonacci(10)  # 55
puts fibonacci(20)  # 6765
