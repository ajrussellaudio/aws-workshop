import { APIGatewayProxyHandler } from "aws-lambda";
import { DynamoDB } from "aws-sdk";
import getenv from "getenv";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandler = async (event) => {
  if (!event.body) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Missing request body" }),
    };
  }
  if (!event.pathParameters || !event.pathParameters.id) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "Missing path parameter: id" }),
    };
  }
  const data = JSON.parse(event.body);

  const updateExpression: string[] = [];
  const expressionAttributeValues: { [key: string]: any } = {};

  if (data.album) {
    updateExpression.push("album = :album");
    expressionAttributeValues[":album"] = data.album;
  }

  if (data.artist) {
    updateExpression.push("artist = :artist");
    expressionAttributeValues[":artist"] = data.artist;
  }

  if (updateExpression.length === 0) {
    return {
      statusCode: 400,
      body: JSON.stringify({ error: "No fields to update" }),
    };
  }

  const params = {
    TableName: getenv("DYNAMODB_TABLE_NAME"),
    Key: {
      id: event.pathParameters.id,
    },
    UpdateExpression: `SET ${updateExpression.join(", ")}`,
    ExpressionAttributeValues: expressionAttributeValues,
    ReturnValues: "ALL_NEW",
  };

  try {
    const result = await dynamoDb.update(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(result.Attributes),
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return {
      statusCode: 500,
      body: JSON.stringify({ error: message }),
    };
  }
};
