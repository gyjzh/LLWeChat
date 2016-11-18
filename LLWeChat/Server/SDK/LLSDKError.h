#import <Foundation/Foundation.h>
#import "EMError.h"
#import "LLSDKErrorCode.h"

/*!
 *  \~chinese 
 *  SDK定义的错误
 *
 *  \~english 
 *  SDK defined error
 */
@interface LLSDKError : NSObject

/*!
 *  \~chinese 
 *  错误码
 *
 *  \~english 
 *  Error code
 */
@property (nonatomic) LLSDKErrorCode errorCode;

/*!
 *  \~chinese 
 *  错误描述
 *
 *  \~english 
 *  Error description
 */
@property (nonatomic, copy) NSString *errorDescription;


/*!
 *  \~chinese 
 *  初始化错误实例
 *
 *  @param aDescription  错误描述
 *  @param aCode         错误码
 *
 *  @result 错误实例
 *
 *  \~english
 *  Initialize a error instance
 *
 *  @param aDescription  Error description
 *  @param aCode         Error code
 *
 *  @result Error instance
 */
- (instancetype)initWithDescription:(NSString *)aDescription
                               code:(LLSDKErrorCode)aCode;

/*!
 *  \~chinese 
 *  创建错误实例
 *
 *  @param aDescription  错误描述
 *  @param aCode         错误码
 *
 *  @result 对象实例
 *
 *  \~english
 *  Create a error instance
 *
 *  @param aDescription  Error description
 *  @param aCode         Error code
 *
 *  @result Error instance
 */
+ (instancetype)errorWithDescription:(NSString *)aDescription
                                code:(LLSDKErrorCode)aCode;

+ (instancetype)errorWithEMError:(EMError *)error;

@end
