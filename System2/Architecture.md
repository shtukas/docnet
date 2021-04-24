
### The local Data Store

Definition: A named hash is a string of the form SHA256-<HEXCODE>, this is to distinguish it from the hash which is just the <HEXCODE> part. Named hashes only exists to carry the name of the hash algorithm that generated the <HEXCODE>. It helps if one day we need to move from one algorithm to another. 

DotNet's raw data is stored as content-addressed datablobs. The naming scheme for these files is

    <namedHash>.data
    <namedHash>.object

The *.data files are binary files and the *.object files are JSON serialization of the DocNet type system. The most important aspect of those files is that they are immutable. We name then after the hash of their contents as a way to ensure the integrity of any collection of files. 

Since files content and names are immutable, synchronising two repositories, or (in the current implementation) a user local data repository and the data server is easy

1. The local instance asks for the server the list of files names the server holds

2. For each filename is that list that the local repository doesn't have, the local instance asks the server to send the file data over. Note that at this point the local instance can compute the hash of the data it receives and compare that with the file name. If they match, this shows that the data has not been corrupted during transport. The local instance write a new file with the correct filename and the data it has received. 

3. The local instance at this moment at at least as many files as the server, but also could have more (files corresponding to operations that have occured on the local instance and that could be broadcasted to the data server). The local instance can then attempt to send the corresponding files to the server, but this operation (which require special permissions) will be made more explicit later.


### The Data Manager 

The Data Manager is the subsystem that implement the logic of the storage and retrieval of raw data from the local server as well as the communication with the remote server.

### The Object Store and the Object Manager


The Object Manager (and its dedicated storage, the Object Store) is where the live objects of the DocNet ecosystem live. In some ways, the Object Store is a projection of the Data Store's object subset.

### The User Interface and the File System Interface

The last two primary sub systems are the User Interface, currently a terminal interface and the File System Interface, which implements the way DocNet objects present themselves to the user in a read-only or read-write fashion.

### Objects

DocNet data is either binary blobs or JSON objects. The generic form of a DocNet JSON object is

```
{
	"objectId"    : String
	"mutationId"  : String
	"timeVersion" : Float
	"type"        : String
    (other key/value pairs...)
}
```

Objects are immutable, once created they never change. This is true to the point that they are stored with a file name that is the named hash of the JSON serialization of the object.  

`objectId` is what remain invariant from one version of an object to another. All versions of the same object carry the same `objectId`. 

`mutationId` is a unique id, actually a uuid. No two objects of the docnet universe have the same `mutationId`.

The reason why we have a `objectId` and an `mutationId` is because in addition of being immutable, objects are never deleted from the object repository. The id maniplated by the logic layer of DocNet is the `objectId`, but a `objectId` maps to one or more `mutationId`s which represent the various mutations of the `objectId`, all immutable files and all stored indefinitely.

Having all those versions of the same logical object around poses the immediate problem of knowing which version is the current one ? The answer is simple, the one with the highest `timeVersion`. 

`timeVersion` is a decimal number, the unixtime with decimals of the time the object is issued.

The type indicates the kind of object. One of the most important object of the DocNet universe is the data carrier, they represent the information that make the documentation. Their type is "b9a1b04f-b27d-4c3f-893a-1614221c36fc".

Yeah the type is that string, instead of something more human, like "DataCarrier" or something. The reason is that I often change my mind about what is the best English word for the type , but since the objects are immutable I can't update them after changing my mind, by having a string that carries no meaning in any language, we still uniquely identify that data type while not exposing myself to the regret of wanting to change it. Note that the type in the source code that could represent this type can still be called **DataCarrier**, but that's fine, if I change my mind I just update the code. 

### Objects Storage

The reason objects carry a type is because each object of the DocNet universe is ultimately essentially stored in the same repository. When we reconstruct the DocNet data from stratch, the type indicates which object it is. We would not have this problem if, say, objects of different types were stored in different tables of a SQL database. In this latter case, the name of the table itself determines the nature of the data. One interesting and important side effect of our conventions is that we can add new types without any change in our storage.

One question the reader may have is "Why is the DocNet storage so.... primitive, and doesn't make use of more moderns solution like a database or something ?" The reason is simple, had DocNet been single user, this would be the case. Instead every detail of the storage conventions exists because we have a multi users system where we want the entire data collection to essentially be an immutable append only self validation repository of content addressed blobs. This makes data synchronisation between instances conceptually far more simple (think how git works), and easily conflict free without any more efforts.


### Data Carriers


DotNet, unlike its 

The payload depends on the type. 

Text, Url, File, Directory

If the type is "Text", then the payload is a named hash, the hash of the blob of text. This implies that the object itself mutates everytime the text is updated. 



