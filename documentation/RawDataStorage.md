### Named Hash

Definition: A named hash is a string of the form 

```
<Hash function identifier>-<HEXCODE>
```

This is to distinguish it from the hash which is just the `<HEXCODE>` part. 

Two examples of named hashes are 

```
SHA1-2fd4e1c67a2d28fced849ee1bb76e7391b93eb12
SHA256-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
```

Named hashes only exist to carry the name of the hash algorithm that generated the `<HEXCODE>`. It helps if one day we need to move from one algorithm to another. 

Note that in DocNet, we use SHA256.

### Content Addressed Storage, general principles.

DocNet's raw data is stored as content-addressed datablobs. The naming scheme for these files is

```
<namedHash>.data
<namedHash>.object
```

The `.data` files are binary files and the `.object` files are JSON serialization of the DocNet network data (eg: nodes, links, arrows, and other metadata). The most important aspect of those files is that they are immutable. We name them after the hash of their contents as a way to make possible to prove the integrity of any collection of files.

Since file contents and file names are immutable, synchronising two user local data stores is trivial. If Alice wants to synchronize her data store with that of Bob's then she can just give him all the files he doesn't have and she can take from him all the files from his repository that she doesn't have. 

### A difference with Camlistore's content addressing.

Note that here we adopt a slightly different convention than Camlistore, by giving the `.data` and `.object` suffix to the filenames. Some JSON objects will actually be stored as `.data` (Notably all those belonging to Aion hierarchies).

The files suffixed `.object` are those that the data manager wants to know about and deserialise when constructing the Object Store from scratch. Camlistore had solved that problem by giving a specific data prefix to those objects, resulting in the first few bytes of each file in the repository needed to be read to test for the presence of that prefix.

This means that when syncthing repositories DocNet will be comparing lists of filesnames, whereas Camlistore was comparing lists of filenames, yes, but was in fact comparing list of named hashes. In either case, though, the content is equality content addressed, and therefore self validating and secure.  