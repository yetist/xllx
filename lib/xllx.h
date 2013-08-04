#ifndef XLLX_TYPE_H
#define XLLX_TYPE_H

#include <pthread.h>

/* XL Error Code */
typedef enum {
    XL_ERROR_OK,
    XL_ERROR_ERROR,
    XL_ERROR_NULL_POINTER,
    XL_ERROR_FILE_NOT_EXIST,
    XL_ERROR_LOGIN_NEED_VC = 10,
    XL_ERROR_NETWORK_ERROR = 20,
    XL_ERROR_HTTP_ERROR = 30,
    XL_ERROR_DB_EXEC_FAIELD = 50,
    XL_ERROR_DB_CLOSE_FAILED,
} XLErrorCode;

typedef struct _VerifyCode VerifyCode;
typedef struct _XLClient XLClient;

XLClient *xl_client_new(const char *username, const char *password);
XLClient *xl_client_set_cookie_path(XLClient *client, const char *path);

#endif  /* XLLX_TYPE_H */
