import file1
import file2
def binarySearch(arr,low,high,x):
	if  high  >=  low :
		mid = ( high  +  low ) / 2
		if  arr [mid] ==  x :
			return mid
		else:
			if  arr [mid] <=  x :
				mid =  mid  - 1
				temp = binarySearch(arr,low,mid,x)
				return temp
			else:
				mid =  mid  + 1
				temp = binarySearch(arr,mid,high,x)
				return temp
	else:
		return -1

def main_func():
	a = [0] * 10
	for i in range(0, 10, 1):
		a[i]= input()

	x= input()

	found = binarySearch(a,0,10,x)
	if  found  == -1:
		print("Element not found")
	else:
		print("Element found at: " + found)

main_func()

