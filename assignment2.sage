'''
	Noah Palmer
	Math 458
	Homework #2

	This is a Sage file, run using the following command:
	$ sage [filename]

	I used the following link to help understand the code for the Elgamal System
	https://www.geeksforgeeks.org/elgamal-encryption-algorithm/
'''

#System Imports
from sage.all import *
import time

#########################################################################################
##### Problem 1
### Part A
print("###1.A:")
print(inverse_mod(38, 97))

### Part B
print("###1.B:")
print(inverse_mod(2^55789, 55789))

#########################################################################################
###### Problem 2
print("###2:")
#on worksheet

#########################################################################################
###### Problem 3
def dlog(A, g, p):
	i = 0
	power = 1
	while i < p:
		if power == A:
			return i
		power = (power * g) % p
		i = i + 1
	return "No Solution"

### Part A
print("###3.A:")
p = 99989
g = 2
nums = [55, 1000, 52381, 52382, 52384]
for num in nums:
	print("dlog(" + str(num) + ") = " +  str(dlog(num, g, p)))

### Part B
print("###3.B:")
p = 99989
g = 2
num = 463141
start = time.time()
dlog(num, g, p)
stop = time.time()
print("time elapsed for dlog(" + str(num) + ") = " + str(stop - start))

num = 884317
start = time.time()
dlog(num, g, p)
stop = time.time()
print("time elapsed for dlog(" + str(num) + ") = " + str(stop - start))

num = 999991
start = time.time()
dlog(num, g, p)
stop = time.time()
print("time elapsed for dlog(" + str(num) + ") = " + str(stop - start))

#########################################################################################
##### Problem 4
def power(n, k, p):
	i = 0
	temp = 1
	while i < k:
		temp = (temp * n) % p
		i = i + 1
	return temp

def fpower(n, k, p):
	if k == 0:
		return 1
	if k == 1:
		return n
	if k % 2 == 0:
		temp = fpower(n, k / 2, p)
		temp = (temp^2) % p
		return temp
	temp = fpower(n, (k - 1) / 2, p)
	temp = (n * temp * temp) % p
	return temp

def timePower(n, k, p):
	start = time.time()
	result = power(n, k, p)
	stop = time.time()
	total = stop - start
	return (result, total)

def timeFpower(n, k, p):
	start = time.time()
	result = fpower(n, k, p)
	stop = time.time()
	total = stop - start
	return (result, total)

### Part A
print("###4.A:")
n = 731
k = 10^3
p = 205433

(result, total) = timePower(n, k, p)
print("power(" + str(n) + "," + str(k) +"," + str(p) + ") = " +  str(result) + " | time = " + str(total))

k =10^8
(result, total) = timePower(n, k, p)
print("power(" + str(n) + "," + str(k) +"," + str(p) + ") = " +  str(result) + " | time = " + str(total))

### Part B
print("###4.B:")
n = 731
k = 10^3
p = 205433

(result, total) = timeFpower(n, k, p)
print("fpower(" + str(n) + "," + str(k) +"," + str(p) + ") = " +  str(result) + " | time = " + str(total))

k = 10^250 #errors if any higher
(result, total) = timeFpower(n, k, p)
print("fpower(" + str(n) + "," + str(k) +"," + str(p) + ") = " +  str(result) + " | time = " + str(total))

#########################################################################################
##### Problem 5
def order(x, p):
	i = 1
	power = x
	while i < p:
		if power == 1:
			return i
		i = i + 1
		power = (power * x) % p
	print("Error")
	return

def is_prim_root(x, p):
	if order(x, p) == p - 1:
		return True
	return False
### Part A
print("###5.A:")
x = 1
p = 29
while not is_prim_root(x, p):
	x = x + 1
print("is_prim_root(" + str(x) + "," + str(p) + ") = True")

### Part B
print("###5.B:")
x = 1
p = 47111
while not is_prim_root(x, p):
	x = x + 1
print("is_prim_root(" + str(x) + "," + str(p) + ") = True")

### Part C
print("###5.C:")
x = 1
count = 0
p = 29
for i in range(1, p):
	x = x + 1
	if is_prim_root(x, p):
		count = count + 1
print("# Prime Roots of " + str(p) + " = " + str(count))

### Part D
print("###5.D:")
x = 1
count = 0
p = 1009
for i in range(1, p):
	x = x + 1
	if is_prim_root(x, p):
		count = count + 1
print("# Prime Roots of " + str(p) + " = " + str(count))

#########################################################################################
##### Problem 6
print("###6:")
def getKey(q):
	key = randint(10^4, q)
	while gcd(q, key) != 1:
		key = randint(10^4, q)
	return key

def encrypt(msg, q, h, g):
	cipher = []
	key = getKey(q)
	print("Key: " + str(key))
	s = fpower(h, key, q)
	p = fpower(g, key, q)

	for i in range(0, len(msg)):
		cipher.append(msg[i])

	for i in range(0, len(cipher)):
		cipher[i] = s * ord(cipher[i])

	return cipher, p

message = "mathmath"
q = randint(pow(10, 4), pow(10, 5))
g = randint(2, q)
key = getKey(q)
h = fpower(g, key, q)

cipher, p = encrypt(message, q, h, g)
print("Cipher: " + str(cipher))

#########################################################################################
##### Problem 7
print("###7:")

def decrypt(cipher, p, key, q):
	plain = []
	h = fpower(p, key, q)
	for i in range(0, len(cipher)):
		plain.append(chr(int(cipher[i] / h)))
	return plain

def decrypt2(y1, y2, a, p):
	return (y2 * (y1 ^ a) ^ -1) % p

plain = decrypt(cipher, p, key, q)
print(str(plain))
A = 3680134
p =  5176489

newcipher = [(1569026, 688774),(3480587, 1098741),(1229690, 1193877),(245823, 4722377),(2130771, 3245424),(3301958, 3959801),(5016045, 4084831),(3240864, 3567288),(3964163, 2474635),(2588970, 2346240)]

for cipher in newcipher:
	print(decrypt2(cipher[0], cipher[1], A, p))

#########################################################################################
##### Problem 8
def show_powers(x, p):
	i = 0
	list = []
	while i < p:
		point = [i, (x^i) % p]
		list.append(point)
		i = i + 1
	graph = points(list)
	show(graph)
	return
	
### Part A
print("###8.A:")
p = 211
x = 2
show_powers(x, p)

x = 64
show_powers(x, p)

for x in range(2, 10):
	show_powers(x, p)

### Part B
print("###8.B:")

for x in range(2, 20):
	show_powers(x, p)

#########################################################################################
##### Problem 9
print("###9:")
#on the worksheet

#########################################################################################
##### Problem 10

### Part A
print("###10.A:")
def nthrootuni(n, p):
	for x in range(1, p-1):
		if (x ^ n) % p == 1:
			print(x)

n = [3, 5, 7, 10]
p = [13, 29, 31, 1009]
for i in n:
	for j in p:
		print("n = " + str(i) + "p = " + str(j))
		nthrootuni(i, j)

### Part B
print("###10.B:")

#########################################################################################
##### Problem 11
print("###11:")
numprimes = 0
numprimroots = 0
x = [2]
for i in range(2, 9999):
	if is_prime(i):
		numprimes = numprimes + 1
		skip = False
		for j in x:
			if is_prim_root(j, i) and not skip:
				skip = True
				numprimroots = numprimroots + 1
temp = float(numprimroots) / float(numprimes) * 100
print("% of primes under 10,000 have " + str(x) + " as prime root: " + str(temp))

numprimes = 0
numprimroots = 0
x = [3]
for i in range(2, 9999):
	if is_prime(i):
		numprimes = numprimes + 1
		skip = False
		for j in x:
			if is_prim_root(j, i) and not skip:
				skip = True
				numprimroots = numprimroots + 1
temp = float(numprimroots) / float(numprimes) * 100
print("% of primes under 10,000 have " + str(x) + " as prime root: " + str(temp))

numprimes = 0
numprimroots = 0
x = [5]
for i in range(2, 9999):
	if is_prime(i):
		numprimes = numprimes + 1
		skip = False
		for j in x:
			if is_prim_root(j, i) and not skip:
				skip = True
				numprimroots = numprimroots + 1
temp = float(numprimroots) / float(numprimes) * 100
print("% of primes under 10,000 have " + str(x) + " as prime root: " + str(temp))

numprimes = 0
numprimroots = 0
x = [2, 3, 5]
for i in range(2, 9999):
	if is_prime(i):
		numprimes = numprimes + 1
		skip = False
		for j in x:
			if is_prim_root(j, i) and not skip:
				skip = True
				numprimroots = numprimroots + 1
temp = float(numprimroots) / float(numprimes) * 100
print("% of primes under 10,000 have " + str(x) + " as prime root: " + str(temp))
