'''
	Noah Palmer
	MATH 458 Cryptography
	Challenge# 1
'''

def main():
	ciphernumbers = [
		268435456, 
		3243919932521508681, 
		4782969, 
		379749833583241, 
		799006685782884121,
		109418989131512359209,
		1283918464548864,
		22876792454961,
		379749833583241,
		6103515625,
		109418989131512359209,
		1638400000000000000,
		29192926025390625,
		109418989131512359209,
		168377826559400929,
		3243919932521508681,
		1,
		4782969,
		379749833583241
	]

	tolerance = .000001

	#cycle through possibilities of N
	for N in range(10, 100):

		#calculate error for each possibility of N, sum to total error
		error = 0
		for ciphernumber in ciphernumbers:
			result = ciphernumber**(1/N)
			error += abs(round(result) - result)

		#if total error is below tolerance, build the plaintext
		if error < tolerance:
			plaintext = ""
			for ciphernumber in ciphernumbers:
				result = chr(round(ciphernumber**(1/N)) + 65 - 1)
				plaintext += " " if result == "[" else result
			print("N:", N, "\nPlain Text:", plaintext)

if __name__ == '__main__':
	main()