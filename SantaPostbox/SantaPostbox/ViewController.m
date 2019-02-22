//Copyright © 2019 Extole. All rights reserved.

#import "ViewController.h"
@import ExtoleKit;

@interface ViewController () <ExtoleAppDelegate>
@property ExtoleApp *app;
@property UILabel *message;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
    
    _message = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 300, 20)];
    [_message setTextColor:[UIColor blackColor]];
    [_message setBackgroundColor:[UIColor clearColor]];
   
    [[self view] addSubview:_message];
    [_message setText:(@"Loading....")];

    _app = ExtoleApp.alloc;
    NSURL *programUrl = [[NSURL alloc] initWithString:(@"https://ios-santa.extole.io")];
    NetworkExecutor* executor = [[NetworkExecutor alloc] init];
    Network* network = [[Network alloc] initWithExecutor:executor];
    ProgramURL *program = [[ProgramURL alloc] initWithBaseUrl:programUrl network:network];
    _app = [[ExtoleApp alloc] initWith:program delegate:self];
    [_app activate];
}


- (void)extoleAppInvalid {
    
}

- (void)extoleAppReadyWithSession:(ConsumerSession * _Nonnull)session {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_message setText:(session.accessToken)];
    });
}

@end
