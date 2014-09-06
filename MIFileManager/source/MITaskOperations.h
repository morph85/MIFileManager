//
//  MITaskOperations.h
//  MIFileManager
//
//  Created by morph85 on 11/30/12.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    TASK_IMAGE_LOAD
    //TASK_OTHER
} TaskOperationType;

@protocol MITaskOperationDelegate <NSObject>
@required
- (void)cancelAllOperations:(TaskOperationType)taskOperationType;
@end

@interface MITaskOperations : NSObject <MITaskOperationDelegate>

// image loader
@property (nonatomic, strong) NSMutableDictionary *imageLoadInProgress;
@property (nonatomic, strong) NSOperationQueue *imageLoadQueue;

// other task queue
//@property (nonatomic, strong) NSMutableDictionary *otherTaskInProgress;
//@property (nonatomic, strong) NSOperationQueue *otherTaskQueue;

@end
