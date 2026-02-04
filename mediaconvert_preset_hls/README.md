## HLS MediaConvert Video Derivative settings

Video derivatives are created within AWS by the MediaConvert service.

The presets (recipes) we use to tell MediaConvert how to create the derivatives are referenced in https://github.com/sciencehistory/scihist_digicoll/blob/master/app/services/create_hls_mediaconvert_job_service.rb .

Terraform doesn't allow us to document the complex settings for video derivatives, but we use the following workaround:

### On AWS:
View the existing settings by clicking "View JSON or Export Json" at the following four URLs:

https://us-east-1.console.aws.amazon.com/mediaconvert/home?region=us-east-1#/presets/details/scihist-hls-extra-low
https://us-east-1.console.aws.amazon.com/mediaconvert/home?region=us-east-1#/presets/details/scihist-hls-low
https://us-east-1.console.aws.amazon.com/mediaconvert/home?region=us-east-1#/presets/details/scihist-hls-medium
https://us-east-1.console.aws.amazon.com/mediaconvert/home?region=us-east-1#/presets/details/scihist-hls-high


### In the digial collections codebase
Compare the settings above to the files at:

https://github.com/sciencehistory/scihist_digicoll/tree/master/infrastructure/aws-mediaconvert

