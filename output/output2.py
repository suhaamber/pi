def factorial(n):
	if  n  == 0:
		return 1
	temp =  n  - 1
	temp2 =  n  * factorial(temp)
	return temp2

def main_func():
	num = 5
	fact = factorial(num)
	print("Factorial of 5 is:" + fact)

main_func()

