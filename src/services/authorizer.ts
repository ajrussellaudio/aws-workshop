import {
  APIGatewayTokenAuthorizerHandler,
  APIGatewayAuthorizerResult,
} from "aws-lambda";
import getenv from "getenv";

const generatePolicy = (
  principalId: string,
  effect: "Allow" | "Deny",
  resource: string
): APIGatewayAuthorizerResult => {
  const authResponse: APIGatewayAuthorizerResult = {
    principalId,
    policyDocument: {
      Version: "2012-10-17",
      Statement: [
        {
          Action: "execute-api:Invoke",
          Effect: effect,
          Resource: resource,
        },
      ],
    },
  };
  return authResponse;
};

export const handler: APIGatewayTokenAuthorizerHandler = async (event) => {
  const token = event.authorizationToken;
  const secret = getenv("AUTH_TOKEN");
  const methodArn = event.methodArn;

  if (token === secret) {
    return generatePolicy("user", "Allow", methodArn);
  } else {
    // Return a 401 Unauthorized response
    throw new Error("Unauthorized");
  }
};
