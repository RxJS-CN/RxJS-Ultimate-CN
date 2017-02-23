#Cascading calls 
As cascading call means that based on what call happening another call should take place and possibly another one based on that.

## Dependant calls
A dependant call means the calls needs to happen in order. Call 2 must happen after Call 1 has returned. It might even be possible that Call2 needs be specified using data from Call 1.

Imagine you have the following scenario:
- A user needs to login first
- Then we can fetch their user details
- Then we can fetch their orders

### Promise approach
### Rxjs approach

## Semi dependant
- We can fetch a users details
- Then we can fetch Orders and Messages in parallell.

### Promise approach
### Rxjs approach

