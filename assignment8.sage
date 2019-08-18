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

def is_nonsing():
    N=(4*elliptic_A^3+27*elliptic_B^2)%elliptic_p
    return (N!=0)

#  Given x and y, returns [gcd,A,B] where gcd(x,y)=Ax+By.  Finds A and B with the Euclidean Algorithm.

def euc_alg(x,y):
    N=y
    d=x
    A1=0                    
    B1=1
    A2=1
    B2=0
    while not(d==0):
        quotient=N//d            # Divide N by d, get the quotient
        remainder=N%d            # and the remainder
        if remainder==0:         # This means we found the gcd at previous step 
            l=[d,A2,B2]          # so just return  
            return l
        Atemp=A1-quotient*A2
        Btemp=B1-quotient*B2
        A1=A2
        B1=B2
        A2=Atemp
        B2=Btemp
        N=d
        d=remainder
    return 0

# Finds the inverse of a in Z/q, if it exists, even when q is not prime.
# Returns 0 if the inverse does not exist

def find_inverse(a,q):
    l=euc_alg(a,q)
    if l[0]==1:
        return l[1]%q
    if l[0]==-1:
        return (0-l[1])%q
    return 0

# This code adds two points l1=[x1,y1] and l2=[x2,y2] in an elliptic curve.
# It assumes that the global variables elliptic_p, elliptic_A, and elliptic_B have been defined already
# Also, the point at infinity is represented by ['I','I'], and we use 'E' to represent an error that occurred.
#
def e_add(l1,l2):
    x1=l1[0]
    x2=l2[0]
    y1=l1[1]
    y2=l2[1]
    if x1=='E':    #If l1 is an "error" point, just return it again as an "error."
        return l1
    if y1=='E':
        return l2
    if x1=='I':               #If l1 is the point at infinity, return l2
        return l2
    if x2=='I':               #If l2 is the point at infinite, return l1
        return l1
    if x1==x2 and ((y1+y2)%elliptic_p==0):  #If l1 and l2 are mirror images of each other, return the point at infinity
        return ['I','I']
    if x1==x2 and y1==y2:                #If the points are the same, use the tangent method
        temp=find_inverse(2*y1,elliptic_p)
        if temp==0:
           return ['E',2*y1]
        temp=temp*(3*x1^2+elliptic_A)
        lambd=temp%elliptic_p       # Note: "lambda" has a special meaning in Python, so can't use it
                                    # for a variable.  We are using "lambd" instead.
    if x1==x2 and y1!=y2:           # Should never encounter this case;
        return ['E','E']            # if we do, return an "error"
    if not(x1==x2):
        temp=find_inverse(x2-x1,elliptic_p)
        if temp==0:
           return ['E',x2-x1]
        lambd=(temp*(y2-y1))%elliptic_p
    x3=lambd^2-x1-x2             # These are the formulas from Theorem 6.6 in the book.
    x3=x3%elliptic_p
    y3=lambd*(x1-x3)-y1
    y3=y3%elliptic_p
    l=[x3,y3]
    return l

# Finds all the points on the given elliptic curve.  Assumes elliptic_p, elliptic_A, and elliptic_B have been defined
# as global variables.

def e_points():
    l=[]
    squares=[]
    x=0
    while x<elliptic_p:
        temp=(x^2)%elliptic_p
        squares.append(temp)
        x=x+1
    x=0
    while x<elliptic_p:
      y2=(x^3+elliptic_A*x+elliptic_B)%elliptic_p
      if squares.count(y2)>0:
           i=squares.index(y2)
           Q=[x,i]
           l.append(Q)
           if not(i==0):
              Q=[x,elliptic_p-i]
              l.append(Q)            
      x=x+1
    l.insert(0,['I','I'])
    return l

def e_power(P,n):  #returns nP, using the fast powering algorithm
    if n==1:
        return P
    if n%2==0:
        temp=e_power(P,n/2)
        temp=e_add(temp,temp)
        return temp
    temp=e_power(P,(n-1)/2)
    temp=e_add(temp,temp)
    temp=e_add(temp,P)
    return temp

# returns the multiplicative order of a in Z/N
# i.e., the smallest value of r such that a^r=1
#
def mult_order(a,N):
    exp=1
    temp=a
    while exp<=N:
        if temp==1:
            return exp
        temp=(temp*a)%N
        exp=exp+1
    print a,'is not a unit'
    return

# returns the additive order of P in the elliptic curve 
# i.e., returns the smallest value of n such that nP=0
#
def e_order(P):
    exp=1
    temp=P
    N=elliptic_p^2
    while exp<=N:
        if temp==['I','I']:
            return exp
        temp=e_add(temp,P)
        exp=exp+1
    print 'Error'
    return

# Performs the Lenstra algorithm for integer factorization using the point P
# (the integer to be factored should be set globally to be the value of elliptic_p )
def lenstra(P):
    n=1
    temp=P
    while n<=50000:
        temp=e_power(temp,n)
        if temp[0]=='E':
            print 'The Lenstra algorithm stopped at',n,'!'
            print 'The number that does not have an inverse is ',temp[1]
            return
        n=n+1
    print 'The algorithm got all the way to 50000! without finding a problem.'
    return

################################################################################################
#5
elliptic_p = 106554589238259677
elliptic_A = 2
elliptic_B = -17
lenstra([3, 4])