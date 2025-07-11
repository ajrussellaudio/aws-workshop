import { APIGatewayProxyHandler } from "aws-lambda";
import { DynamoDB } from "aws-sdk";
import { v4 as uuidv4 } from "uuid";
import getenv from "getenv";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandler = async (event) => {
  if (!event.body) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Missing request body" }),
    };
  }
  const data = JSON.parse(event.body);

  if (!data.album || !data.artist) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Missing album or artist in request body" }),
    };
  }

  const params = {
    TableName: getenv("DYNAMODB_TABLE_NAME"),
    Item: {
      id: uuidv4(),
      gsi_1_pk: "item",
      album: data.album,
      artist: data.artist,
      createdAt: new Date().toISOString(),
    },
  };

  try {
    await dynamoDb.put(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(params.Item),
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return {
      statusCode: 500,
      body: JSON.stringify({ error: message }),
    };
  }
};
