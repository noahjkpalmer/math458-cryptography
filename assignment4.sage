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
    if e==0:
        return 1
    if e==1:
        return x%p
    if e%2==0:
        output=fastpower(x,e/2,p)
        output=(output*output)%p
        return output
    output=fastpower(x,(e-1)/2,p)
    output=(output*output*x)%p
    return output

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

def sortFirst(a):
    return a[0]

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

def miller_rabin_test(n,a):
    k=0
    temp=n-1
    while (temp%2)==0:
        k=k+1
        temp=temp/2
    q=(n-1)/(2^k)
    A=fastpower(a,q,n)
    if A==1:
        return False
    i=0
    while i<=k-1:
        if A==n-1:
            return False
        A=(A**2)%n
        i=i+1
    return True

##############################################################################
#3 part B
def count_mr(n):
    count = 0
    for i in range(1, n):
        if miller_rabin_test(n, i):
            count = count + 1
    return count / (n - 1)

# print 90, ": ", count_mr(90)
# print 243, ": ", count_mr(243)
# print 928, ": ", count_mr(928)
# print 1104, ": ", count_mr(1104)
# print 7386, ": ", count_mr(7386)

#3 part C
# total = 0
# for j in range(2, 10000):
#     if j % 1000 == 0:
#         print(j)
#     total = total + count_mr(j)
# print(numerical_approx(total) / 9999)

#3 part D
for j in range(2, 2000):
    temp = numerical_approx(count_mr(j))
    if temp < 0.85 and temp > 0.1:
        print(j, ":", temp)




