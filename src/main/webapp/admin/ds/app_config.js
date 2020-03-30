_modelid = "SWBForms";
//_dataStore = "embedmongodb";
_dataStore = "mongodb";
//_dataStore = "ts_leveldb";
roles={prog:"Programador", su:"Super User",admin:"Administrator",user:"User"};
eng.config.appName="SWBForms";
eng.config.appURL="https://github.com/SWBForms2";
eng.config.appSkin="skin-blue";
eng.config.version=1.0
eng.config.compileDS=false;                                         //compile admin_db.js
eng.config.AUTH_TYPE="DEFAULT"; //DEFAULT, LDAP 
// IF AUTH_TYPE == LDAP
eng.config.LDAP={
    INITIAL_CONTEXT_FACTORY:"com.sun.jndi.ldap.LdapCtxFactory",
    PROVIDER_URL:"ldap://192.168.97.22",
    SEARCH_NAME:"DC=infotec,DC=mx",
    OBJECT_CLASS:"person",
    SECURITY_AUTHENTICATION:"Simple",
    REFERRAL:"follow",
    SYNCUSER:true,
    USER_FULLNAME:"name",  //cn, 
    USER_NAME:"givenName",
    USER_SNAME:"sn",
    USER_LASTNAME:"extensionAttribute3",
    USER_SECONDLASTNAME:"extensionAttribute4",
    USER_EMAIL:"mail",
    USER_THUMBNAIL:"thumbnailPhoto",
    //USER_EXTATTR1:"extensionAttribute3",
    //USER_EXTATTR2:"extensionAttribute4",
    USER_EXTATTR3:"extensionAttribute6",
    USER_EXTATTR4:"extensionAttribute5",
    USER_EXTATTR5:"extensionAttribute7"
};

 


//LDAP USER PROPERTIES

//userPrincipalName (user@infotec.mx), 
//description (Institucional), 
//mailNickname (username), 
//msExchUserCulture (es-MX)
//streetAddress (INFOTEC), 
//title (Consultor), 
//distinguishedName (CN=User Fullname,OU=Direccion Adjunta de Competitividad,OU=Corporativo,DC=infotec,DC=mx), 
//mail (user.mail@infotec.mx), 
//manager (CN=Manager Name,OU=Bajas,DC=infotec,DC=mx), 
//department (Direccion Adjunta de Competitividad), 
//co (Mexico), 
//cn (User Fullname), 
//postalCode (14050), 
//initials (user initials), 
//l (Mexico), 
//c (MX), 
//company (Infotec), 
//maxStorage (536870912), 
//countryCode (484), 
//physicalDeliveryOfficeName (Segundo Piso), 
//name (User Fullname),
//extensionAttribute7(MASCULINO), 
//extensionAttribute6(RFC), 
//extensionAttribute5(CURP), 
//extensionAttribute4(Apellido 2), 
//extensionAttribute3(Apellido 1), 
//telephoneNumber(0000), //extensión 
//postOfficeBox (14050),  //C.P.
//sAMAccountName (username),
//st (Distrito Federal), 
//msRTCSIP-FederationEnabled (TRUE),
//msRTCSIP-InternetAccessEnabled (TRUE)
//objectClass (top, person, user, organizationalPerson), 
//sn (apellidos usuario), 
//givenName (Nombre usuario), 
//displayName (username fullname), 
//thumbnailPhoto (byte[]), //DOWNLOAD