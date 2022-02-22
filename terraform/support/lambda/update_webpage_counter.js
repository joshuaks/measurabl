'use strict;'

const initDbClient = require('aws-sdk').DynamoDB.DocumentClient;

const getValue = async function getValue(docClient, tableName, webpage){
  let result = "";
  
  const params = {
    TableName: process.env.TABLE_NAME,
    Key: {
      webpage: process.env.WEB_PAGE,
    }
  }

  console.log( "Get params : ", params); 

  try {
    const data = await docClient.get(params).promise();
    console.log( "Status code : 200"); 
    result = data.Item.view_count
  } catch (error){
    console.log( "Status code : 400, Error code : ", error.stack);
  }

  return Number(result);
}


const updateValue = async function updateValue(docClient, value, tableName, webPage){
  const newValue = Number(value) + 1

  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      webpage: process.env.WEB_PAGE,
      view_count: Number(newValue)
    }
  }
  console.log( "Put params : ", params); 

  try {
    const data = await docClient.put(params).promise();
    console.log( "Status code : 200", data); 
  } catch (error){
    console.log( "Status code : 400, Error code : ", error.stack);
  }

  return Number(newValue)
}


exports.handler = async function(event) {
  const docClient = new initDbClient();
  const count     = getValue(docClient).then( value => updateValue(docClient, value) );
  return count;
}
