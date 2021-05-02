### Transmutation

Transmutation is the process of changing the payload type of a Data Carrier. There are many reasons why this could happen. 
For instance, you create a new node of type Text and fill it with information and it get well connected with the rest of the network. 
Then, later on, you realise that actually you need to 
add some pictures and it it should better be a .md file (which given the current Data Carrier payload types means being a Directory / Aion Point). 
You would not want to create a new node, because you would end up with two nodes 
carrying essentially the same information, one being well connected to the rest of the network and the new one disconnected. 
Ideally, if you could, you would like to create the new node and plug it to the network with the same nodeId as the old one (essentially 
creating a mutation). This is transmutation. 

In the above we saw a case of transmutation from a "simple" payload type to a more complex one, but the opposite is possible. 
Your Directory with hundred of files may have been replaced by a website, and you simply want to transmute it to a Node of type Url.
