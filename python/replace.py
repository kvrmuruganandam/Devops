with open('test.txt','U') as f:
 newText=f.read().replace('ping ', 'ping hi')
 
with open('test.txt', "w") as f:
 f.write(newText)
