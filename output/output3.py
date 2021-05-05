def main_func():
	a = [[0] * 5] * 5
	b = [[0] * 5] * 5
	c = [[0] * 5] * 5
	for i in range(0, 5, 1):
		c[i][i] =  a [i][i] +  b [i][i]
	for i in range(0, 5, 1):
		print(c[i][i])

main_func()

