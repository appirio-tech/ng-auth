window.FIXTURES = {
    "bower_components/appirio-tech-api-schemas/v3.json": {
        "swagger": "2.0",
        "info": {
                "description": "",
                "version": "",
                "title": ""
        },
        "host": "api.topcoder-dev.com",
        "basePath": "/v3/events",
        "schemes": [
                "https"
        ],
        "produces": [
                "application/json"
        ],
        "paths": {
                "": {
                        "get": {
                                "responses": {
                                        "200": {
                                                "schema": {
                                                        "type": "object",
                                                        "items": {
                                                                "$ref": "#/definitions/Event"
                                                        }
                                                }
                                        },
                                        "default": {
                                                "description": "Unexpected error",
                                                "schema": {
                                                        "$ref": "#/definitions/Error"
                                                }
                                        }
                                }
                        }
                }
        },
        "definitions": {
                "Event": {
                        "properties": {
                                "id": {
                                        "type": "string"
                                },
                                "result": {
                                        "type": "object",
                                        "items": {
                                                "$ref": "#/definitions/EventResult"
                                        }
                                }
                        }
                },
                "EventResult": {
                        "properties": {
                                "content": {
                                        "type": "array",
                                        "items": {
                                                "$ref": "#/definitions/EventContent"
                                        }
                                }
                        }
                },
                "EventContent": {
                        "properties": {
                                "version": {
                                        "type": "number"
                                },
                                "id": {
                                        "type": "string"
                                },
                                "modifiedBy": {
                                        "type": "string"
                                },
                                "modifiedAt": {
                                        "type": "string",
                                        "sample": "2015-05-05T20:53:41.467Z"
                                },
                                "createdBy": {
                                        "type": "string"
                                },
                                "createdAt": {
                                        "type": "string",
                                        "sample": "2015-05-05T20:53:41.467Z"
                                },
                                "ownerId": {
                                        "type": "string"
                                },
                                "sourceObjectType": {
                                        "type": "string",
                                        "enum": [
                                                "app-work-requests"
                                        ]
                                },
                                "sourceObjectId": {
                                        "type": "string"
                                },
                                "eventType": {
                                        "type": "string",
                                        "enum": [
                                                "timeline"
                                        ]
                                },
                                "eventSubType": {
                                        "type": "string",
                                        "enum": [
                                                "copilot-assigned",
                                                "created",
                                                "submitted",
                                                "quote-created",
                                                "email-verified",
                                                "payment-accepted",
                                                "challenge-feedback-provided",
                                                "challenge-submission",
                                                "challenge-member-registered",
                                                "challenge-finalists-selected",
                                                "state-change",
                                                "launched",
                                                "checkpoint1",
                                                "finalists",
                                                "final-design",
                                                "winner",
                                                "final-feedback",
                                                "completed"
                                        ]
                                },
                                "sourceObjectContent": {
                                        "type": "object",
                                        "items": {
                                                "$ref": "#/definitions/SourceObjectContent"
                                        }
                                },
                                "userId": {
                                        "type": "string"
                                },
                                "fieldChanges": {
                                        "type": "string"
                                }
                        }
                },
                "SourceObjectContent": {
                        "properties": {
                                "copilotId": {
                                        "type": "string"
                                },
                                "challengeId": {
                                        "type": "string"
                                },
                                "submissionId": {
                                        "type": "string",
                                        "sample": "200703"
                                },
                                "submissionType": {
                                        "type": "string",
                                        "enum": [
                                                "final",
                                                "checkpoint"
                                        ]
                                },
                                "handle": {
                                        "type": "string",
                                        "sample": "Batman9000"
                                },
                                "submissionDate": {
                                        "type": "string",
                                        "sample": "2015-05-05T20:53:41.467Z"
                                },
                                "submissionStatus": {
                                        "type": "string"
                                },
                                "registrationDate": {
                                        "type": "string",
                                        "sample": "2015-05-05T20:53:41.467Z"
                                }
                        }
                },
                "Error": {
                        "properties": {
                                "code": {
                                        "type": "integer",
                                        "format": "int32"
                                },
                                "message": {
                                        "type": "string"
                                },
                                "fields": {
                                        "type": "string"
                                }
                        }
                }
        }
},
    "bower_components/appirio-tech-api-schemas/v2.json": {
        "swagger": "2.0",
        "info": {
                "description": "Move your app forward with the Uber API",
                "version": "1.0.0",
                "title": "Uber API"
        },
        "host": "api.topcoder-dev.com",
        "basePath": "/v2",
        "schemes": [
                "https"
        ],
        "produces": [
                "application/json"
        ],
        "paths": {
                "/users/{handle}": {
                        "get": {
                                "responses": {
                                        "200": {
                                                "schema": {
                                                        "type": "object",
                                                        "items": {
                                                                "$ref": "#/definitions/User"
                                                        }
                                                }
                                        },
                                        "default": {
                                                "description": "Unexpected error",
                                                "schema": {
                                                        "$ref": "#/definitions/Error"
                                                }
                                        }
                                }
                        }
                }
        },
        "definitions": {
                "User": {
                        "properties": {
                                "handle": {
                                        "type": "string",
                                        "sample": "CardioBoy"
                                },
                                "country": {
                                        "type": "string",
                                        "sample": "Idonesia"
                                },
                                "memberSince": {
                                        "type": "string",
                                        "sample": "2008-10-15T05:08:00.000-0400"
                                },
                                "quote": {
                                        "type": "string",
                                        "sample": "Don't forget your roots."
                                },
                                "photoLink": {
                                        "type": "string",
                                        "sample": "/i/m/cardiboy_big.jpg"
                                }
                        }
                }
        }
},
    "bower_components/appirio-tech-api-schemas/v3-authorizations.json": {
        "swagger": "2.0",
        "info": {
                "description": "",
                "version": "",
                "title": ""
        },
        "host": "api.topcoder-dev.com",
        "basePath": "/v3/authorizations",
        "schemes": [
                "https"
        ],
        "produces": [
                "application/json"
        ],
        "paths": {
                "": {
                        "post": {
                                "responses": {
                                        "200": {
                                                "schema": {
                                                        "type": "object",
                                                        "items": {
                                                                "$ref": "#/definitions/Authorization"
                                                        }
                                                }
                                        },
                                        "default": {
                                                "description": "Unexpected error",
                                                "schema": {
                                                        "$ref": "#/definitions/Error"
                                                }
                                        }
                                }
                        },
                        "delete": {
                                "responses": {
                                        "200": {
                                                "schema": {
                                                        "type": "object",
                                                        "items": {
                                                                "$ref": "#/definitions/Authorization"
                                                        }
                                                }
                                        },
                                        "default": {
                                                "description": "Unexpected error",
                                                "schema": {
                                                        "$ref": "#/definitions/Error"
                                                }
                                        }
                                }
                        }
                },
                "/{id}": {
                        "get": {
                                "responses": {
                                        "200": {
                                                "schema": {
                                                        "type": "object",
                                                        "items": {
                                                                "$ref": "#/definitions/Authorization"
                                                        }
                                                }
                                        },
                                        "default": {
                                                "description": "Unexpected error",
                                                "schema": {
                                                        "$ref": "#/definitions/Error"
                                                }
                                        }
                                }
                        }
                }
        },
        "definitions": {
                "Authorization": {
                        "properties": {
                                "id": {
                                        "type": "string"
                                },
                                "result": {
                                        "type": "object",
                                        "items": {
                                                "$ref": "#/definitions/AuthorizationResult"
                                        }
                                }
                        }
                },
                "AuthorizationResult": {
                        "properties": {
                                "success": {
                                        "type": "boolean",
                                        "sample": true
                                },
                                "status": {
                                        "type": "integer",
                                        "sample": 200
                                },
                                "content": {
                                        "type": "array",
                                        "items": {
                                                "$ref": "#/definitions/AuthorizationContent"
                                        }
                                }
                        }
                },
                "AuthorizationContent": {
                        "properties": {
                                "id": {
                                        "type": "string"
                                },
                                "token": {
                                        "type": "string"
                                },
                                "target": {
                                        "type": "string",
                                        "sample": "1"
                                }
                        }
                },
                "Error": {
                        "properties": {
                                "code": {
                                        "type": "integer",
                                        "format": "int32"
                                },
                                "message": {
                                        "type": "string"
                                },
                                "fields": {
                                        "type": "string"
                                }
                        }
                }
        }
}
};