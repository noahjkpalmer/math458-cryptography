import time

def shanks(p,g,h):      # Solves g^x=h in F_p using the Shanks algorithm.  
    n=floor(p**0.5)+1
    list_a=[]
    i=0
    temp=1
    print 'Producing the list of powers of g...',
    while i<=n-1:
        list_a.append( [temp,i] )
        temp=(temp*g)%p
        i=i+1
    print 'done.'                # list_a now contains [g^0,0],[g^1,1],..,[g^{n-1},n-1]
                                 # We are keeping track of both the power AND the exponent to make our life
                                 # easier later
    print 'Producing the list of h*g^{-jn}...',
    list_b=[]
    ginv=fastpower(g,p-2,p)
    u=fastpower(ginv,n,p)
    i=0
    temp=h
    while i<=n-1:
        list_b.append( temp)
        temp=(temp*u)%p
        i=i+1
    print 'done.'               # list_b now contains hg^0,h*g^{-n},h*g^{-2n},...,h*g^{-(n-1)n}
    print 'Starting collision algorithm for two lists of length', len(list_a)
    
    l=collision(list_a,list_b)  # Do the collision algorithm.  l[0]=i will be the index in the first list
                                # and l[1]=j will be the index in the second list
    if l=='F':
        print "\n There is no solution"
        return
    return l[0]+n*l[1]          # The solution is x=i+n*j.

def fastpower(x,e,p):           # Compute x^e in Z/p using the fast powering algorithm
    temp=1
    list=[]
    if e==0:
        return 1
    while e>0:
        if e%2==0:
            list.append(2)
            e=e/2
            continue
        list.append(1)
        e=e-1
        continue
    a=list.pop()
    temp=x
    while len(list)>0:
        a=list.pop()
        if a==1:
            temp=(temp*x)%p
            continue
        temp=(temp*temp)%p
    return temp

def collision(l,m):          #Given two lists l=[(a0,b0),(a1,b1),...] and m=[x0,x1,x2,...]
                             #having the same length, see if some ai matches an xj.
                             #If no, return 'F' for 'Fail'.
    i=0                      #If yes, return the pair [i,j] giving the indices for the matching elements
    print 'Sorting the first list...',

    l.sort(key=sortFirst)  #First sort the list l so that a0<=a1<=a2<=...
    print 'done.'               #This can take a while for very long lists.
    print 'Testing elements of the second list...', 
    i=0                         #Now test elements of m one by one to see if they match one of the ai terms.
    n=len(m)
    while i<=n-1:
        if i%100==0:
           print '.',
        x=m[i]
        u=is_in(l,x)      #The function is_in decides if x matches one of the ai
        if u=='F':
            i=i+1
            continue
        print 'done'
        return [u,i]
    print 'done.'
    return 'F'

def is_in(l,x):          #Given l=[[a0,b0],[a1,b1],...] and x, decide if x equals one of the ai.
                         #Use the method of "compare to middle term" and divide the problem in half.
    if len(l)==0:        #If no, return 'F'.  If yes, return the bi.  
        return 'F'       #Assumes that a0<=a1<=a2<=... from the beginning.
    first=0           
    last=len(l)-1        #Set up pointers "first" and "last", originally at the start and end of the list l.
    while first<last:
        middle=first+((last-first)//2)  #Go to roughly the middle term
        u=l[middle][0]                  #and pull out the a-value
        if u==x:                        #If it matches our x, return the corresponding b-value.
            return l[middle][1]
        if u<x:                         #If x is bigger, reset the pointers to look at the last half of the list
            first=middle+1              #and repeat
            continue
        last=middle-1                   #If x is smaller, reset the pointers to look at the first half of the list.
                                        #If we come out of the loop, we never found our x.
    if first>last:                      #Either we exhausted all elements, or we narrowed it down to exactly one.
        return 'F'
    u=l[first]
    if u[0]==x:                         #Do one last check to see if we have the x.
        return u[1]
    return 'F'

def findprime(lower,upper,tries):
    i=1
    while i<=tries:
        a=randint(lower,upper)
        if is_prime(a):
            return a
        i=i+1
    print 'None found'
    return 0

def order(x,p):
    i=1
    temp=x
    while i<=p:
#        if i%100==0:
#          print '\r testing ',i,
        if temp==1:
            return i
        temp=(temp*x)%p
        i=i+1
    print 'Error'
    return

def find_prim_gen(p):     # Find a primitive generator for F_p
    x=2                   # Warning: For big primes (9 or more digits) this can take a while.
    while x<=p-1:
        print 'Testing ',x,'...',
        u=order(x,p)
        print 'Order is ',u,'...',
        if u==p-1:
            print 'So found a generator'
            return x
        print 'So not a generator'
        x=x+1
    print 'Error'
    return

def dlp_naive(p,g,h):   # Solve g^x=h in Z/p, given g and h.  Uses the brute force algorithm.  
    i=0                 # i keeps track of the exponent we are trying
    temp=1              #Start with g^0
    while i<=p:
        if temp==h:     #if we found it, return the exponent
            return i
        temp=(temp*g)%p # Otherwise multiply by one more copy of g and increase i.
        i=i+1
    print 'Error: no solution found'
    return

def ph_estimate(n):
    i=1
    save=0
    while i<=n:
        b=findprime(10^20,10^21,35)
        if b==0:
            continue
        l=factor(b-1)
        count=0
        for a in l:
            count=count+a[1]*a[0]
        save=save+(b+0.0)/count
        i=i+1
    return (save+0.0)/n

def miller_rabin_witness(n,a):   # Determines if a is a Miller-Rabin witness for n
    k=0                          # Returns True or False, accordingly
    temp=n-1
    while (temp%2)==0:           # First divide n-1 by 2 repeatedly, until we can't 
        k=k+1                    # do so anymore.
        temp=temp/2
    q=(n-1)/(2^k)                # Have n-1 = 2^k * q where q is odd
    A=fastpower(a,q,n)           # A=a^q in Z/n
    if A==1:                     # If a^q=1, we DON'T have a M-R witness
        return False
    i=0
    while i<=k-1:
        if A==n-1:               # Now test to see if A=-1 in Z/n
            return False
        A=(A**2)%n               # If not, square A and continue the loop
        i=i+1
                                 # If we get here then none of a^q,a^{2q},...,a^{2^{k-1}q}
    return True                  # equal -1 in Z/n, so we DO have a M-R witness

def count_mrw(n):           # This counts the number of Miller-Rabin witnesses for n
    i=1
    count=0
    while i<=n-1:
        if miller_rabin_witness(n,i):
            count=count+1
        i=i+1
    return count

def miller_rabin_test(n,k):   # Randomly choose a number between 2 and n-1
    i=1                   # and check if it is a M-R witness for n.
    while i<=k:           # If yes, return it
        a=randint(2,n-1) # If no, do it again...but stop after k tries.
        if miller_rabin_witness(n,a):
            print 'The number is composite: a Miller-Rabin witness is',a
            return
        i=i+1
    print 'The number is probably prime'
    return

def is_prime_mr(n,k):     #Test if n is prime using Miller-Rabin, k times
    if n==2:
        return True
    if n==1: 
        return False
    j=1
    while j<=k:
        a=randint(2,n-1)
        if miller_rabin_witness(n,a)==True:
            return False
        j=j+1
#    print "Probably prime"
    return True

def findaprime_mr(lower,upper,trials):
    i=1
    while i<=trials:
        a=randint(lower,upper)
        if is_prime_mr(a,10):
            return a
        i=i+1
    print 'No prime found'
    return 0

def pollard(N,bound):   # Perform Pollard's p-1 algorithm
    a=2                 # to factor N, using "bound" as the number of steps in the loop.
    j=2                 # See page 139 of the text.  
    while j<=bound:
        a=(a^j)%N
        d=gcd(a-1,N)
        if 1<d and d<N:
            return d    # Have found a nontrivial factor, so return it
        j=j+1
    print 'No factor found'
    return

###############################################################################
#3.18 part a
# l = [10, 25, 100]
# for ele in l:
#     print(ele)
#     one = []
#     three = []
#     for i in range(3, ele):
#         if is_prime(i):
#             if i % 4 == 1:
#                 one.append(i)
#             if i % 4 == 3:
#                 three.append(i)
#     print("one:", len(one))
#     print("three:", len(three))

#3.18 part b
# l = [100, 1000, 10000]
# for ele in l:
#     print(ele)
#     one = []
#     three = []
#     for i in range(3, ele):
#         if is_prime(i):
#             if i % 4 == 1:
#                 one.append(i)
#             if i % 4 == 3:
#                 three.append(i)
#     print("one:", len(one))
#     print("three:", len(three))
#     print("three/one:", len(three) * 1.0 / len(one))

#2 part a
# mp = []
# i = 2
# while len(mp) < 15:
#     t = 2^i - 1
#     i = i + 1
#     if is_prime(t):
#         mp.append(t)
#     if i % 1000:
#         print("1k")
    
# print(mp)

#2 part c
# mp = []
# i = 2
# while len(mp) < 15:
#     t = 2^(i*3) - 1
#     i = i + 1
#     if is_prime(t):
#         mp.append(t)
#     if i % 1000:
#         print("1k")
    
# print(mp)

#3 part a
# miller_rabin_test(10001, 5)
# is_prime_mr(10001, 10)

#3 part b
# print(is_prime(2^1279 - 1))

#3 part c
# print(is_prime_mr(2^1279 - 1, 10))

#3 part d
# print(2^19937 - 1)

#3 part e
# start = time.time()
# print(is_prime_mr(2^19937 - 1, 10))
# stop = time.time()
# print("time elapse:", stop - start)

#3 part f
# for k in [2, 3, .., 5000]:
#     if is_prime(k) != is_prime_mr(k, 3):
#         print(k)

#4 part a
# success = 0
# for i in range(0, 100):
#     if findaprime_mr(1, 10**20, 100) != 0:
#         success = success + 1
# print(success)

#4 part b
# success = 0
# for i in range(0, 45):
#     if findaprime_mr(1, 10**20, 100) != 0:
#         success = success + 1
# print(success)

#4 part c
# success = 0
# for i in range(0, 100):
#     if findaprime_mr(1, 10**20, 50) != 0:
#         success = success + 1
# print(100 - success)

#4 part d
# start = time.time()
# print(findaprime_mr(10**499, 10**500, 1000))
# stop = time.time()
# print("time elapsed:", stop - start)

#6 part a
# print(pollard(54844953941717, 151))