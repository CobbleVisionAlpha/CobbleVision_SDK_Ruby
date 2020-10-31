###################
# Environment setup
###################

$valid_price_categories=Array.New("high", "medium", "low")
$valid_job_types=Array.New("QueuedJob")

$serverAdress = "https://cobblevision.com"
$debugging=false


$apiUserName = ""
$apiToken = ""

$environmentType==false

if(environmentType==false || environmentType==="demo")
  $BaseURL = "https://www.cobblevision.com/api/"
else
  $BaseURL = serverAdress + "/api/"
  
 
################################################
# Handy functions for setting auth and debug
################################################

# Function allows you to set the Username and Token for CobbleVision
# @function setApiAuth()
# @param {String} apiusername
# @param {String} apitoken
# @returns {Boolean} Indicating success of setting Api Auth.

def setAPIAuth(apiusername, apitoken)
  self.apiUserName = apiusername
  self.apiPassword = apitoken
  return true
end

# Function allows you to set the debugging variable
# @function setDebugging()
# @param {Boolean} debugBool
# @returns {Boolean} Indicating success of setting Api Auth.

def setDebugging(debugBool)
  self.debugging = debugBool
  return true
end

################################################
# Functions for using the CobbleVision API
################################################

# Return of the following functions is specified within this type description
# @typedef {Object} Response
# @property {String} code() Returns Status Code of Response
# @method {String / Object} body() returns response body

# This function uploads a media file to CobbleVision. You can find it after login in your media storage. Returns a response object with body, response and headers properties, deducted from npm request module
# @async
# @function uploadMediaFile()  
# @param {string} price_category - Either high, medium, low
# @param {boolean} publicBool - Make Media available publicly or not?
# @param {string} name - Name of Media (Non Unique)
# @param {array} tags - Tag Names for Media - Array of Strings
# @param {buffer} file - File as Base64 String
# @returns {Response} This returns the UploadMediaResponse. The body is in JSON format.

async def uploadMediaFile(price_category, publicBool, name, keys, file)
  begin
    endpoint="media"
    if self.BaseURL[self.BaseURL.length-1] != "/"
      raise "BaseURL must end with a slash - / !"
    end
    
    keyArray = Array.New("price_category", "publicBool", "name", "tags", "Your Api User Key!", "Your API Token!")
    valueArray = Array.New(price_category, publicBool, name, tags, apiUserName, apiToken)
    typeArray = Array.new("String", "Boolean", "String", "Array", "String", "String")
    
    begin
      checkTypeOfParameter(valueArray, typeArray)
    raise Exception
      err_message = Integer(e.Message)
      if err_message.is_u?(Integer)
        raise "The provided data is not valid: " + keyArray[err_message] + "is not of type: " + typeArray[err_message]
      else
        raise e.Message
      end
    end
    
    if self.valid_price_categories.find_index(price_category) == -1
      raise "Price Category is not valid!"
    end
    
    request = NET:HTTP:Post.new URI(BaseURL + endpoint)
    request.body = {"price_category" => price_category, "public" => publicBool, "name" => name, "tags" => tags, "file" => file.encode(ISO-85591, "UTF-8"}.to_json
    request.basic_auth(apiUserName, apiToken)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    response = http.request request
    
    if debugBool
      logger.info(response.to_string)
    end
    
    return response
  rescue Exception
    if debugBool
      logger.error(e.Message)
    end
    raise Exception(e.Message)
  end
end

# This function deletes Media from CobbleVision
# @async
# @function deleteMediaFile()  
# @param {array} IDArray Array of ID's as Strings
# @returns {Response} This return the DeleteMediaResponse. The body is in JSON format.

async def deleteMediaFile(IDArray)
  begin
    endpoint="media"
    
    if self.BaseURL[self.BaseURL.length-1] != "/"
      raise "BaseURL must end with a slash - / !"
    end
    
    keyArray = Array.New("IDArray", "Your Api User Key!", "Your API Token!")
    valueArray = Array.New(IDArray, apiUserName, apiToken)
    typeArray = Array.new("String", "String", "String")
    
    begin
      checkTypeOfParameter(valueArray, typeArray)
    raise Exception
      err_message = Integer(e.Message)
      if err_message.is_u?(Integer)
        raise "The provided data is not valid: " + keyArray[err_message] + "is not of type: " + typeArray[err_message]
      else
        raise e.Message
      end
    end
    
    invalidMedia = checkMongooseObjectIDArray(IDArray)
    
    if invalidMedia.length > 0
      raise Exception "You sent an invalid media ID!"
    end
    
    request = NET:HTTP:Delete.new URI(BaseURL + endpoint + "?id=" + IDArray.to_json)
    request.basic_auth(apiUserName, apiToken)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    response = http.request request
    
     if debugBool
      logger.info(response.to_string)
    end
    
    return response
  rescue Exception
    if debugBool
      logger.error(e.Message)
    end
    raise Exception(e.Message)
  end
end

# Launch a calculation with CobbleVision's Web API. Returns a response object with body, response and headers properties, deducted from npm request module;
# @async
# @function launchCalculation() 
# @param {array} algorithms Array of Algorithm Names
# @param {array} media Array of Media ID's  
# @param {string} type Type of Job - Currently Always "QueuedJob"
# @param {string} [notificationURL] Optional - Notify user upon finishing calculation!
# @returns {Response} This returns the LaunchCalculationResponse. The body is in JSON format.  
    
async def launchCalculation(algorithms, media, type, notificationURL)
  begin
    endpoint="calculation"
    
    if(self.BaseURL[self.BaseURL.length-1] != "/")
      raise "BaseURL must end with a slash - / !"
    end
    
    keyArray = Array.New("algorithms", "media", "type", "notificationURL", "Your Api User Key!", "Your API Token!")
    valueArray = Array.New(algorithms, media, type, notificationURL, apiUserName, apiToken)
    typeArray = Array.new("Array", "Array", "String", "String", "String", "String")
    
    begin
      checkTypeOfParameter(valueArray, typeArray)
    raise Exception
      err_message = Integer(e.Message)
      if err_message.is_u?(Integer)
        raise "The provided data is not valid: " + keyArray[err_message] + "is not of type: " + typeArray[err_message]
      else
        raise e.Message
      end
    end
    
    if self.valid_job_types.find_index(type) == -1
      raise "Type is not valid!"
    end
    
    invalidMedia = checkMongooseObjectIDArray(media)
      
    invalidAlgorithms = checkMongooseObjectIDArray(algorithms)
    
    if invalidMedia.length > 0
      raise Exception "You sent an invalid media ID!"
    end
    
    if invalidAlgorithms.length > 0
      raise Exception "You sent an invalid algorithm ID!"
    end
    
    if notificationURL != nil && notificationURL =~ URL::regexp
      raise Exception "Provided URL is not valid!"
    end
    
    jsonHash = Hash.new()
    jsonHash = {"algorithms" => algorithms, "media" => media, "type" => type}
    
    if notificationURL != nil
      jsonHash[notificationURL] = notificationURL
    end
    
    request = NET:HTTP:Post.new URI(BaseURL + endpoint)
    request.body = JSON.generate(jsonHash)
    request.basic_auth(apiUserName, apiToken)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    response = http.request request
    
    if debugBool
      logger.info(response.to_string)
    end
    
    return response
  rescue Exception
    if debugBool
      logger.error(e.Message)
    end
    raise Exception(e.Message)
  end
end

# This function waits until the given calculation ID's are ready to be downloaded!
# @async
# @function waitForCalculationCompletion() 
# @param {array} calculationIDArray Array of Calculation ID's
# @returns {Response} This returns the WaitForCalculationResponse. The body is in JSON format.   

async def waitForCalculationCompletion(calculationIDArray)
  begin
    endpoint="calculation"
    
    if self.BaseURL[self.BaseURL.length-1] != "/"
      raise "BaseURL must end with a slash - / !"
    end
    
    keyArray = Array.New("calculationIDArray", "Your Api User Key!", "Your API Token!")
    valueArray = Array.New(calculationIDArray, apiUserName, apiToken)
    typeArray = Array.new("Array", "String", "String")
    
    begin
      checkTypeOfParameter(valueArray, typeArray)
    raise Exception
      err_message = Integer(e.Message)
      if err_message.is_u?(Integer)
        raise "The provided data is not valid: " + keyArray[err_message] + "is not of type: " + typeArray[err_message]
      else
        raise e.Message
      end
    end
    
    invalidCalculations = checkMongooseObjectIDArray(calculationIDArray)
    
    if invalidCalculations.length > 0
      raise Exception "You sent an invalid calculation ID!"
    end
    
    request = NET:HTTP:Get.new URI(BaseURL + endpoint + "?id=" + calculationIDArray.to_json + "&returnOnlyStatusBool=true")
    request.basic_auth(apiUserName, apiToken)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
      
    calculationFinishedBool = false
    
    while calculationFinishedBool == false
      response = http.request request
      if response.body.kind_of?(Array) #Need to verify how arrays are parsed by ruby json. Might crash here.
        for respElement in response.body
          if defined? respElement.status
            if respElement.status === "finished"
              calculationFinishedBool = true
            else
              calculationFinishedBool = false
              break
            end
          else
            calculationFinishedBool = false
          end
      else
        if defined? respElement.error
          calculationFinishedBool = true
        end
      end
      
      if calculationFinishedBool = false
        sleep(3000)
      end
    end
    
    if debugBool
      logger.info(response.to_string)
    end
    
    return response
  rescue Exception
    if debugBool
      logger.error(e.Message)
    end
    raise Exception(e.Message)
  end
end

# This function deletes Result Files or calculations in status "waiting" from CobbleVision. You cannot delete finished jobs beyond their result files, as we keep them for billing purposes.
# @async
# @function deleteCalculation()
# @param {array} IDArray Array of ID's as Strings
# @returns {Response} This returns the DeleteCalculationResponse. The body is in JSON format.

async def deleteCalculation(IDArray)
  begin
    endpoint="calculation"
    
    if self.BaseURL[self.BaseURL.length-1] != "/"
      raise "BaseURL must end with a slash - / !"
    end
    
    keyArray = Array.New("IDArray", "Your Api User Key!", "Your API Token!")
    valueArray = Array.New(IDArray, apiUserName, apiToken)
    typeArray = Array.new("String", "String", "String")
    
    begin
      checkTypeOfParameter(valueArray, typeArray)
    raise Exception
      err_message = Integer(e.Message)
      if err_message.is_u?(Integer)
        raise "The provided data is not valid: " + keyArray[err_message] + "is not of type: " + typeArray[err_message]
      else
        raise e.Message
      end
    end
    
    invalidCalcs = checkMongooseObjectIDArray(IDArray)
    
    if invalidCalcs.length > 0
      raise Exception "You sent an invalid calculation ID!"
    end
    
    request = NET:HTTP:Delete.new URI(BaseURL + endpoint + "?id=" + IDArray.to_json)
    request.basic_auth(apiUserName, apiToken)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    response = http.request request
    
    if debugBool
      logger.info(response.to_string)
    end
    
    return response
  rescue Exception
    if debugBool
      logger.error(e.Message)
    end
    raise Exception(e.Message)
  end
end

# Get Calculation Result with CobbleVision's Web API. Returns a response object with body, response and headers properties, deducted from npm request module;
# @async
# @function getCalculationResult()
# @param {array} IDArray ID of calculation to return result Array 
# @param {boolean} returnOnlyStatusBool Return full result or only status? See Doc for more detailed description!
# @returns {Response} This returns the GetCalculationResult. The body is in json format.

async def getCalculationResult(IDArray, returnOnlyStatusBool)
  begin
    endpoint="calculation"
    
    if self.BaseURL[self.BaseURL.length-1] != "/"
      raise "BaseURL must end with a slash - / !"
    end
    
    keyArray = Array.New("IDArray", "returnOnlyStatusBool", "Your Api User Key!", "Your API Token!")
    valueArray = Array.New(calculationIDArray, returnOnlyStatusBool, apiUserName, apiToken)
    typeArray = Array.new("Array", "Boolean", "String", "String")
    
    begin
      checkTypeOfParameter(valueArray, typeArray)
    raise Exception
      err_message = Integer(e.Message)
      if err_message.is_u?(Integer)
        raise "The provided data is not valid: " + keyArray[err_message] + "is not of type: " + typeArray[err_message]
      else
        raise e.Message
      end
    end
    
    invalidCalculations = checkMongooseObjectIDArray(calculationIDArray)
    
    if invalidCalculations.length > 0
      raise Exception "You sent an invalid calculation ID!"
    end
    
    request = NET:HTTP:Get.new URI(BaseURL + endpoint + "?id=" + calculationIDArray.to_json + "&returnOnlyStatusBool=" + returnOnlyStatusBool.to_string)
    request.basic_auth(apiUserName, apiToken)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    response = http.request request
    
    if debugBool
      logger.info(response.to_string)
    end
    
    return response
  rescue Exception
    if debugBool
      logger.error(e.Message)
    end
    raise Exception(e.Message)
  end
end

# Request your calculation result by ID with the CobbleVision API. Returns a response object with body, response and headers properties, deducted from npm request module;
# @async
# @function getCalculationVisualization()
# @param {string} id ID of calculation to return result/check String
# @param {boolean} returnBase64Bool Return Base64 String or image buffer as string?
# @param {integer} width target width of visualization file
# @param {integer} height target height of visualization file
# @returns {Response} This returns the GetCalculationVisualization Result. The body is in binary format.
 
async def getCalculationVisualization(id, returnBase64Bool, width, height)
  begin
    endpoint="calculation/visualization"
    
    if(self.BaseURL[self.BaseURL.length-1] != "/")
      raise "BaseURL must end with a slash - / !"
    end
    
    keyArray = Array.New("id", "returnBase64Bool", "width", ,"height", "Your Api User Key!", "Your API Token!")
    valueArray = Array.New(id, returnBase64Bool, width, height, apiUserName, apiToken)
    typeArray = Array.new("String", "Boolean", "Integer", "Integer", "String", "String")
    
    begin
      checkTypeOfParameter(valueArray, typeArray)
    raise Exception
      err_message = Integer(e.Message)
      if err_message.is_u?(Integer)
        raise "The provided data is not valid: " + keyArray[err_message] + "is not of type: " + typeArray[err_message]
      else
        raise e.Message
      end
    end
    
    invalidCalcs = checkMongooseObjectIDArray(Array.new(id))
      
    if invalidCalcs.length > 0
      raise Exception "You sent an invalid calculation ID!"
    end
    
    request = NET:HTTP:Post.new URI(BaseURL + endpoint + "?id=" + id + "&returnBase64Bool=" + returnBase64Bool.to_string + "&width=" + width.to_string + "&height=" + height.to_string)
    request.basic_auth(apiUserName, apiToken)
    request["Content-Type"] = "application/json"
    request["Accept"] = "application/json"
    response = http.request request
    
    if debugBool
      logger.info(response.to_string)
    end
    
    return response
  rescue Exception
    if debugBool
      logger.error(e.Message)
    end
    raise Exception(e.Message)
  end
end

###################################################
## Helper Functions
###################################################

# TypeChecking of Values
# @sync
# @function checktypeOfParameter()
# @param {array} targetArray Array of values to be checked
# @param {array} typeArray Array of types in strings to be checked against
# @returns {boolean} Success of Check

def checkTypeOfParameter(targetArray, assertTypeArray)
  begin
  
    targetArray.each_with_index do |targetElement, index|
      if targetArray[index].class.name.split("::").last != assertTypeArray[index]
        if assertTypeArray[index] === "Array"
          if !(is_array(targetArray[index]))
              raise Exception index.to_string
          end
        else
          raise Exception index.to_string
        end
      end
    end
    
    return true
  rescue Exception
    raise Exception e.Message
  end
end

# Check Array of Mongo IDs for Invalid Values
# @sync
# @function checkIDArrayForInvalidValues()
# @param {array} IDArray Array of Mongo IDs
# @returns {boolean} Success of Check

def checkMongooseObjectIDArray(IDArray)
  begin
    IDArray.each_with_index do |id, index|
      id =~ /\A[a-f0-9]AZ'/i
      if idArray[i] == 0
        raise Exception "IDArray containts invalid id"
      end
    end
    return true
  rescue Exception
    raise e.Message
  end
end
    


