//
//  TableViewController.m
//  SimpleControl
//
//  Created by Cheong on 7/11/12.
//  Copyright (c) 2012 RedBearLab. All rights reserved.
//

#import "TableViewController.h"
#import "AFNetworking.h"

@interface TableViewController () {
    BOOL on;
}

@end

@implementation TableViewController

@synthesize ble;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    on = NO;

    ble = [[BLE alloc] init];
    [ble controlSetup:1];
    ble.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - BLE delegate

- (void)bleDidDisconnect {
    NSLog(@"->Disconnected");

    [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
    [indConnecting stopAnimating];
    
    lblAnalogIn.enabled = false;
    swDigitalOut.enabled = false;
    swDigitalIn.enabled = false;
    swAnalogIn.enabled = false;
    sldPWM.enabled = false;
    sldServo.enabled = false;
    
    lblRSSI.text = @"---";
 //   lblAnalogIn.text = @"----";
}

// When RSSI is changed, this will be called
-(void) bleDidUpdateRSSI:(NSNumber *) rssi {
    lblRSSI.text = rssi.stringValue;
}

// When disconnected, this will be called
-(void) bleDidConnect {
    NSLog(@"->Connected");

    [indConnecting stopAnimating];
    
    lblAnalogIn.enabled = true;
    swDigitalOut.enabled = true;
    swDigitalIn.enabled = true;
    swAnalogIn.enabled = true;
    sldPWM.enabled = true;
    sldServo.enabled = true;
    
    swDigitalOut.on = false;
    swDigitalIn.on = false;
    swAnalogIn.on = false;
    sldPWM.value = 0;
    sldServo.value = 0;
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length {
    NSLog(@"Length: %d", length);

    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3) {
        NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);

        if (data[i] == 0x0A) {
            if (data[i+1] == 0x01) {
                swDigitalIn.on = true;
            } else {
                swDigitalIn.on = false;
            }
        }
        else if (data[i] == 0x0B) {
            UInt16 Value;
            
            Value = data[i+2] | data[i+1] << 8;
            lblAnalogIn.text = [NSString stringWithFormat:@"%d", Value];
        }        
    }
}

#pragma mark - Actions

// Connect button will call to this
- (IBAction)btnScanForPeripherals:(id)sender {
    if (ble.activePeripheral) {
        if(ble.activePeripheral.isConnected) {
            [[ble CM] cancelPeripheralConnection:[ble activePeripheral]];
            [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
            return;
        }
    }
    
    if (ble.peripherals) {
        ble.peripherals = nil;
    }
    
    [btnConnect setEnabled:false];
    [ble findBLEPeripherals:2];
    
    [NSTimer scheduledTimerWithTimeInterval:(float)2.0 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
    
    [indConnecting startAnimating];
}

-(void) connectionTimer:(NSTimer *)timer {
    [btnConnect setEnabled:true];
    [btnConnect setTitle:@"Disconnect" forState:UIControlStateNormal];
    
    if (ble.peripherals.count > 0)
    {
        [ble connectPeripheral:[ble.peripherals objectAtIndex:0]];
    }
    else
    {
        [btnConnect setTitle:@"Connect" forState:UIControlStateNormal];
        [indConnecting stopAnimating];
    }
}

-(void)sendData {
    NSURL *url = [NSURL URLWithString:@"http://gspbetagroup-userstream.herokuapp.com/twitter/FreedomRiders1.json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        
        NSString *status = [JSON objectForKey:@"status"];

        
        if( ![status isEqualToString:@"OK"] ) {
            NSLog(@"Error in parsing data.");
        } else {
            NSString *type = [JSON objectForKey:@"type"];
            NSArray *payload = [JSON objectForKey:@"payload"];
            if( [type isEqualToString:@"twitter"] ) {
                UInt8 buf[4] = { 0x00, 0x00, 0x00, 0x00 };
                if (on) {
                    buf[0] = 0x00;
                    on = NO;
                } else {
                    buf[0] = 0x01;
                    on = YES;
                }
                for (NSDictionary *tweet in payload) {
                    NSString *name = [tweet objectForKey: @"name"];
//                    NSString *text = [tweet objectForKey:@"text" ];
                    
//                    if( [name isEqualToString:@"AustinTest2"] ) {
//                        NSLog(@"tweet austin 2");
//                        buf[1] = 0x01;
//                    } else if( [name isEqualToString:@"chrisallick"] ) {
//                        NSLog(@"tweet mike newell");
//                        buf[2] = 0x01;
//                    } else if( [name isEqualToString:@"newshorts"] ) {
                    if( [name isEqualToString:@"newshorts"] ) {
                        NSLog(@"tweet from mike");
                        buf[3] = 0x01;
                    }
                    
                    NSData *data = [[NSData alloc] initWithBytes:buf length:4];
                    [ble write:data];
                }
            }
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON){
        UInt8 buf[4] = { 0x00, 0x00, 0x00, 0x00};
        
        buf[0] = 0x00;
        on = NO;
        
        NSData *data = [[NSData alloc] initWithBytes:buf length:4];
        [ble write:data];
        
        NSLog(@"Error making AJAX request.");
    }];
    [operation start];
}

-(IBAction)sendDigitalOut:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(sendData) userInfo:nil repeats:YES];
}

/* Send command to Arduino to enable analog reading */
-(IBAction)sendAnalogIn:(id)sender {
    UInt8 buf[3] = {0xA0, 0x00, 0x00};
    
    if (swAnalogIn.on)
        buf[1] = 0x01;
    else
        buf[1] = 0x00;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

// PWM slide will call this to send its value to Arduino
-(IBAction)sendPWM:(id)sender {
    UInt8 buf[3] = {0x02, 0x00, 0x00};
    
    buf[1] = sldPWM.value;
    buf[2] = (int)sldPWM.value >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

// Servo slider will call this to send its value to Arduino
-(IBAction)sendServo:(id)sender {
    UInt8 buf[3] = {0x03, 0x00, 0x00};
    
    buf[1] = sldServo.value;
    buf[2] = (int)sldServo.value >> 8;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [ble write:data];
}

@end
