import { APIGatewayProxyHandler } from "aws-lambda";
import { DynamoDB } from "aws-sdk";
import getenv from "getenv";

const dynamoDb = new DynamoDB.DocumentClient();

export const handler: APIGatewayProxyHandler = async (_event) => {
  const params = {
    TableName: getenv("DYNAMODB_TABLE_NAME"),
    IndexName: "gsi_1",
    KeyConditionExpression: "gsi_1_pk = :gsi_1_pk",
    ExpressionAttributeValues: {
      ":gsi_1_pk": "item",
    },
  };

  try {
    const result = await dynamoDb.query(params).promise();
    return {
      statusCode: 200,
      body: JSON.stringify(result.Items),
    };
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return {
      statusCode: 500,
      body: JSON.stringify({ error: message }),
    };
  }
};
