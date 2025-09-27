# Automatic Auth

## Auth Endpoint Post-Response Script

```js
const token = res.body?.access_token;

if (token) {
  bru.setGlobalEnvVar("<REPACE_ME>-api-token", token);
  bru.setGlobalEnvVar(
    "<REPACE_ME>-api-token-exp-ms",
    (Date.now() + res.body.expires_in * 1000).toString()
  );
}
```

## Collection/Folder Pre-Request Script

```js
async function do_auth() {
  console.log("Auth not present or expired. (Re-)Authing");
  const res = await bru.runRequest("Get Token");
  if (res.status != 200) {
      console.error("Failed to authenticate", res);
      bru.setNextRequest(null);
  }    
}

if (req.getName() != 'Get Token') {
  const token = bru.getGlobalEnvVar("<REPLACE_ME>-api-token");
  const exp = bru.getGlobalEnvVar("<REPLACE_ME>-api-token-exp-ms");
  
  if (!token || (exp && (parseInt(exp) < Date.now()))) {
    do_auth();
  }
}
```
