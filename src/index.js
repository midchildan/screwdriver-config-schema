"use strict";

const parse = require("joi-to-json");
const sd = require("screwdriver-data-schema");

// Workaround joi-to-json bug. JOI objects allows any child keys by default, but
// joi-to-json does the opposite.
function fix(joiSchema) {
  return joiSchema.prefs({
    allowUnknown: true,
  });
}

const sdConfig = parse(fix(sd.config.base.configBeforeMergingTemplate));
const job = parse(fix(sd.config.job.job));
const jobName = sd.config.regex.JOB_NAME.source;
const image = parse(sd.config.job.image);
const environment = parse(sd.config.job.environment);
const settings = parse(fix(sd.config.job.settings));
const requires = parse(sd.config.job.requires);
const sourcePaths = parse(sd.config.job.sourcePaths);

// Manually fix joi-to-json limitations
//
// > Currently, if the joi condition definition is referring to another field,
// > the If-Then-Else style output is not supported.

sdConfig.properties.jobs = {
  type: "object",
  additionalProperties: false,
  patternProperties: {
    [`${jobName}`]: job,
  },
};

sdConfig.properties.cache.properties.job = {
  type: "object",
  additionalProperties: false,
  patternProperties: {
    [`${jobName}`]: {
      type: "array",
      items: {
        type: "string",
        format: "uri",
      },
    },
  },
};

sdConfig.if = {
  properties: {
    template: {
      type: "string",
    },
  },
  required: ["template"],
};
sdConfig.then = {
  properties: {
    shared: {
      type: "object",
      additionalProperties: false,
      properties: {
        image,
        environment,
        settings,
        requires,
        sourcePaths,
      },
    },
  },
};
sdConfig.else = {
  properties: {
    shared: job,
  },
  required: ["jobs"],
};

sdConfig.properties.shared = {};

console.log(JSON.stringify(sdConfig, null, 2));
