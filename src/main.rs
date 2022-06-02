use std::fs;
use std::io;
use std::str::FromStr;

//use serde::{Deserialize, Serialize};
use serde_json::{Value as JSONValue};

use rusqlite::MappedRows;
use rusqlite::NO_PARAMS;
use rusqlite::{params, Connection, Error};

//#[derive(Serialize, Deserialize)]
#[derive(Debug)]
struct LibrarianObject {
    uuid: String,
    raw_object: JSONValue
}

fn string_to_json_value(str: &String) -> JSONValue {
    serde_json::from_str(str).expect("error during JSON deserialisation")
}

fn get_librarian_objects(conn: &Connection) -> Result<Vec<LibrarianObject>, Error> {
    let mut stmt = conn.prepare("SELECT _objectuuid_, _object_ FROM _objects_")?;
    let rows = stmt.query_map(NO_PARAMS, |row| {
        let uuid: String  = row.get(0).unwrap();
        let raw_string: String = row.get(1).unwrap();
        Ok((uuid, raw_string))
    })?;
    
    let mut objects = Vec::new();
    for element in rows {
        let tuple = element.unwrap();
        objects.push(
            LibrarianObject{
                uuid: tuple.0,
                raw_object: string_to_json_value(&tuple.1)
            }
        );
    }
    Ok(objects)
}

fn main() -> Result<(), Error> {
    println!("Welcome to DotNet");

    //println!("Please enter your name: ");
    //let mut buffer = String::new();
    //io::stdin().read_line(&mut buffer)?;

    let conn = Connection::open("/Users/pascal/Galaxy/DataBank/Stargate/objects-store.sqlite3")?;

    let objects = get_librarian_objects(&conn).unwrap();

    for object in objects {
        println!("uuid from database: {}, {:?}", object.uuid, object.raw_object)
    }

    Ok(())
}
