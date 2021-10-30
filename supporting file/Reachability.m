//
//  AccountCreateViewController.swift
//  iPray
//
//  Created by vivek on 15/03/17.
//  Copyright © 2017 TrivialWorks. All rights reserved.
//

#import "Reachability.h"

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>


NSString *const kReachabilityChangedNotification = @"kReachabilityChangedNotification";


@interface Reachability ()

@property (nonatomic, assign) SCNetworkReachabilityRef  reachabilityRef;
@property (nonatomic, strong) dispatch_queue_t          reachabilitySerialQueue;
@property (nonatomic, strong) id                        reachabilityObject;

-(void)reachabilityChanged:(SCNetworkReachabilityFlags)flags;
-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags;

@end


static NSString *reachabilityFlags(SCNetworkReachabilityFlags flags) 
{
    return [NSString stringWithFormat:@"%c%c %c%c%c%c%c%c%c",
#if	TARGET_OS_IPHONE
            (flags & kSCNetworkReachabilityFlagsIsWWAN)               ? 'W' : '-',
#else
            'X',
#endif
            (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
            (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
            (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
            (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
            (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
            (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-'];
}

// Start listening for reachability notifications on the current run loop
static void TMReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info) 
{
#pragma unused (target)

    Reachability *reachability = ((__bridge Reachability*)info);

    // We probably don't need an autoreleasepool here, as GCD docs state each queue has its own autorelease pool,
    // but what the heck eh?
    @autoreleasepool 
    {
        [reachability reachabilityChanged:flags];
    }
}


@implementation Reachability

#pragma mark - Class Constructor Methods

+(Reachability*)reachabilityWithHostName:(NSString*)hostname
{
    return [Reachability reachabilityWithHostname:hostname];
}

+(Reachability*)reachabilityWithHostname:(NSString*)hostname
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [hostname UTF8String]);
    if (ref) 
    {
        id reachability = [[self alloc] initWithReachabilityRef:ref];

        return reachability;
    }
    
    return nil;
}

+(Reachability *)reachabilityWithAddress:(void *)hostAddress
{
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    if (ref) 
    {
        id reachability = [[self alloc] initWithReachabilityRef:ref];
        
        return reachability;
    }
    
    return nil;
}

+(Reachability *)reachabilityForInternetConnection 
{   
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    return [self reachabilityWithAddress:&zeroAddress];
}

+(Reachability*)reachabilityForLocalWiFi
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len            = sizeof(localWifiAddress);
    localWifiAddress.sin_family         = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr    = htonl(IN_LINKLOCALNETNUM);
    
    return [self reachabilityWithAddress:&localWifiAddress];
}


// Initialization methods

-(Reachability *)initWithReachabilityRef:(SCNetworkReachabilityRef)ref 
{
    self = [super init];
    if (self != nil) 
    {
        self.reachableOnWWAN = YES;
        self.reachabilityRef = ref;

        // We need to create a serial queue.
        // We allocate this once for the lifetime of the notifier.

        self.reachabilitySerialQueue = dispatch_queue_create("com.tonymillion.reachability", NULL);
    }
    
    return self;    
}

-(void)dealloc
{
    [self stopNotifier];

    if(self.reachabilityRef)
    {
        CFRelease(self.reachabilityRef);
        self.reachabilityRef = nil;
    }

	self.reachableBlock          = nil;
	self.unreachableBlock        = nil;
    self.reachabilitySerialQueue = nil;
}

#pragma mark - Notifier Methods

// Notifier 
// NOTE: This uses GCD to trigger the blocks - they *WILL NOT* be called on THE MAIN THREAD
// - In other words DO NOT DO ANY UI UPDATES IN THE BLOCKS.
//   INSTEAD USE dispatch_async(dispatch_get_main_queue(), ^{UISTUFF}) (or dispatch_sync if you want)

-(BOOL)startNotifier
{
    // allow start notifier to be called multiple times
    if(self.reachabilityObject && (self.reachabilityObject == self))
    {
        return YES;
    }


    SCNetworkReachabilityContext    context = { 0, NULL, NULL, NULL, NULL };
    context.info = (__bridge void *)self;

    if(SCNetworkReachabilitySetCallback(self.reachabilityRef, TMReachabilityCallback, &context))
    {
        // Set it as our reachability queue, which will retain the queue
        if(SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, self.reachabilitySerialQueue))
        {
            // this should do a retain on ourself, so as long as we're in notifier mode we shouldn't disappear out from under ourselves
            // woah
            self.reachabilityObject = self;
            return YES;
        }
        else
        {
#ifdef DEBUG
            NSLog(@"SCNetworkReachabilitySetDispatchQueue() failed: %s", SCErrorString(SCError()));
#endif

            // UH OH - FAILURE - stop any callbacks!
            SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
        }
    }
    else
    {
#ifdef DEBUG
        NSLog(@"SCNetworkReachabilitySetCallback() failed: %s", SCErrorString(SCError()));
#endif
    }

    // if we get here we fail at the internet
    self.reachabilityObject = nil;
    return NO;
}

-(void)stopNotifier
{
    // First stop, any callbacks!
    SCNetworkReachabilitySetCallback(self.reachabilityRef, NULL, NULL);
    
    // Unregister target from the GCD serial dispatch queue.
    SCNetworkReachabilitySetDispatchQueue(self.reachabilityRef, NULL);

    self.reachabilityObject = nil;
}

#pragma mark - reachability tests

// This is for the case where you flick the airplane mode;
// you end up getting something like this:
//Reachability: WR ct-----
//Reachability: -- -------
//Reachability: WR ct-----
//Reachability: -- -------
// We treat this as 4 UNREACHABLE triggers - really apple should do better than this

#define testcase (kSCNetworkReachabilityFlagsConnectionRequired | kSCNetworkReachabilityFlagsTransientConnection)

-(BOOL)isReachableWithFlags:(SCNetworkReachabilityFlags)flags
{
    BOOL connectionUP = YES;
    
    if(!(flags & kSCNetworkReachabilityFlagsReachable))
        connectionUP = NO;
    
    if( (flags & testcase) == testcase )
        connectionUP = NO;
    
#if	TARGET_OS_IPHONE
    if(flags & kSCNetworkReachabilityFlagsIsWWAN)
    {
        // We're on 3G.
        if(!self.reachableOnWWAN)
        {
            // We don't want to connect when on 3G.
            connectionUP = NO;
        }
    }
#endif
    
    return connectionUP;
}

-(BOOL)isReachable
{
    SCNetworkReachabilityFlags flags;  
    
    if(!SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
        return NO;
    
    return [self isReachableWithFlags:flags];
}

-(BOOL)isReachableViaWWAN 
{
#if	TARGET_OS_IPHONE

    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        // Check we're REACHABLE
        if(flags & kSCNetworkReachabilityFlagsReachable)
        {
            // Now, check we're on WWAN
            if(flags & kSCNetworkReachabilityFlagsIsWWAN)
            {
                return YES;
            }
        }
    }
#endif
    
    return NO;
}

-(BOOL)isReachableViaWiFi 
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
        // Check we're reachable
        if((flags & kSCNetworkReachabilityFlagsReachable))
        {
#if	TARGET_OS_IPHONE
            // Check we're NOT on WWAN
            if((flags & kSCNetworkReachabilityFlagsIsWWAN))
            {
                return NO;
            }
#endif
            return YES;
        }
    }
    
    return NO;
}


// WWAN may be available, but not active until a connection has been established.
// WiFi may require a connection for VPN on Demand.
-(BOOL)isConnectionRequired
{
    return [self connectionRequired];
}

-(BOOL)connectionRequired
{
    SCNetworkReachabilityFlags flags;
	
	if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
		return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
	}
    
    return NO;
}

// Dynamic, on demand connection?
-(BOOL)isConnectionOnDemand
{
	SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & (kSCNetworkReachabilityFlagsConnectionOnTraffic | kSCNetworkReachabilityFlagsConnectionOnDemand)));
	}
	
	return NO;
}

// Is user intervention required?
-(BOOL)isInterventionRequired
{
    SCNetworkReachabilityFlags flags;
	
	if (SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags))
    {
		return ((flags & kSCNetworkReachabilityFlagsConnectionRequired) &&
				(flags & kSCNetworkReachabilityFlagsInterventionRequired));
	}
	
	return NO;
}


#pragma mark - reachability status stuff

-(NetworkStatus)currentReachabilityStatus
{
    if([self isReachable])
    {
        if([self isReachableViaWiFi])
            return ReachableViaWiFi;
        
#if	TARGET_OS_IPHONE
        return ReachableViaWWAN;
#endif
    }
    
    return NotReachable;
}

-(SCNetworkReachabilityFlags)reachabilityFlags
{
    SCNetworkReachabilityFlags flags = 0;
    
    if(SCNetworkReachabilityGetFlags(self.reachabilityRef, &flags)) 
    {
        return flags;
    }
    
    return 0;
}

-(NSString*)currentReachabilityString
{
	NetworkStatus temp = [self currentReachabilityStatus];
	
	if(temp == ReachableViaWWAN)
	{
        // Updated for the fact that we have CDMA phones now!
		return NSLocalizedString(@"Cellular", @"");
	}
	if (temp == ReachableViaWiFi) 
	{
		return NSLocalizedString(@"WiFi", @"");
	}
	
	return NSLocalizedString(@"No Connection", @"");
}

-(NSString*)currentReachabilityFlags
{
    return reachabilityFlags([self reachabilityFlags]);
}

#pragma mark - Callback function calls this method

-(void)reachabilityChanged:(SCNetworkReachabilityFlags)flags
{
    if([self isReachableWithFlags:flags])
    {
        if(self.reachableBlock)
        {
            self.reachableBlock(self);
        }
    }
    else
    {
        if(self.unreachableBlock)
        {
            self.unreachableBlock(self);
        }
    }
    
    // this makes sure the change notification happens on the MAIN THREAD
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kReachabilityChangedNotification 
                                                            object:self];
    });
}

#pragma mark - Debug Description

- (NSString *) description
{
    NSString *description = [NSString stringWithFormat:@"<%@: %#x (%@)>",
                             NSStringFromClass([self class]), (unsigned int) self, [self currentReachabilityFlags]];
    return description;
}


+(NSString*)getCountryCallingCode:(NSString*)countryRegionCode
{
    
    NSDictionary *diction = @{
                              @"Canada"                                       : @"+1",
                              @"China"                                        : @"+86",
                              @"France"                                       : @"+33",
                              @"Germany"                                      : @"+49",
                              @"India"                                        : @"+91",
                              @"Japan"                                        : @"+81",
                              @"Pakistan"                                     : @"+92",
                              @"United Kingdom"                               : @"+44",
                              @"United States"                                : @"+1",
                              @"Abkhazia"                                     : @"+7 840",
                              @"Abkhazia"                                     : @"+7 940",
                              @"Afghanistan"                                  : @"+93",
                              @"Albania"                                      : @"+355",
                              @"Algeria"                                      : @"+213",
                              @"American Samoa"                               : @"+1 684",
                              @"Andorra"                                      : @"+376",
                              @"Angola"                                       : @"+244",
                              @"Anguilla"                                     : @"+1 264",
                              @"Antigua and Barbuda"                          : @"+1 268",
                              @"Argentina"                                    : @"+54",
                              @"Armenia"                                      : @"+374",
                              @"Aruba"                                        : @"+297",
                              @"Ascension"                                    : @"+247",
                              @"Australia"                                    : @"+61",
                              @"Australian External Territories"              : @"+672",
                              @"Austria"                                      : @"+43",
                              @"Azerbaijan"                                   : @"+994",
                              @"Bahamas"                                      : @"+1 242",
                              @"Bahrain"                                      : @"+973",
                              @"Bangladesh"                                   : @"+880",
                              @"Barbados"                                     : @"+1 246",
                              @"Barbuda"                                      : @"+1 268",
                              @"Belarus"                                      : @"+375",
                              @"Belgium"                                      : @"+32",
                              @"Belize"                                       : @"+501",
                              @"Benin"                                        : @"+229",
                              @"Bermuda"                                      : @"+1 441",
                              @"Bhutan"                                       : @"+975",
                              @"Bolivia"                                      : @"+591",
                              @"Bosnia and Herzegovina"                       : @"+387",
                              @"Botswana"                                     : @"+267",
                              @"Brazil"                                       : @"+55",
                              @"British Indian Ocean Territory"               : @"+246",
                              @"British Virgin Islands"                       : @"+1 284",
                              @"Brunei"                                       : @"+673",
                              @"Bulgaria"                                     : @"+359",
                              @"Burkina Faso"                                 : @"+226",
                              @"Burundi"                                      : @"+257",
                              @"Cambodia"                                     : @"+855",
                              @"Cameroon"                                     : @"+237",
                              @"Canada"                                       : @"+1",
                              @"Cape Verde"                                   : @"+238",
                              @"Cayman Islands"                               : @"+ 345",
                              @"Central African Republic"                     : @"+236",
                              @"Chad"                                         : @"+235",
                              @"Chile"                                        : @"+56",
                              @"China"                                        : @"+86",
                              @"Christmas Island"                             : @"+61",
                              @"Cocos-Keeling Islands"                        : @"+61",
                              @"Colombia"                                     : @"+57",
                              @"Comoros"                                      : @"+269",
                              @"Congo"                                        : @"+242",
                              @"Congo, Dem. Rep. of (Zaire)"                  : @"+243",
                              @"Cook Islands"                                 : @"+682",
                              @"Costa Rica"                                   : @"+506",
                              @"Ivory Coast"                                  : @"+225",
                              @"Croatia"                                      : @"+385",
                              @"Cuba"                                         : @"+53",
                              @"Curacao"                                      : @"+599",
                              @"Cyprus"                                       : @"+537",
                              @"Czech Republic"                               : @"+420",
                              @"Denmark"                                      : @"+45",
                              @"Diego Garcia"                                 : @"+246",
                              @"Djibouti"                                     : @"+253",
                              @"Dominica"                                     : @"+1 767",
                              @"Dominican Republic"                           : @"+1 809",
                              @"Dominican Republic"                           : @"+1 829",
                              @"Dominican Republic"                           : @"+1 849",
                              @"East Timor"                                   : @"+670",
                              @"Easter Island"                                : @"+56",
                              @"Ecuador"                                      : @"+593",
                              @"Egypt"                                        : @"+20",
                              @"El Salvador"                                  : @"+503",
                              @"Equatorial Guinea"                            : @"+240",
                              @"Eritrea"                                      : @"+291",
                              @"Estonia"                                      : @"+372",
                              @"Ethiopia"                                     : @"+251",
                              @"Falkland Islands"                             : @"+500",
                              @"Faroe Islands"                                : @"+298",
                              @"Fiji"                                         : @"+679",
                              @"Finland"                                      : @"+358",
                              @"France"                                       : @"+33",
                              @"French Antilles"                              : @"+596",
                              @"French Guiana"                                : @"+594",
                              @"French Polynesia"                             : @"+689",
                              @"Gabon"                                        : @"+241",
                              @"Gambia"                                       : @"+220",
                              @"Georgia"                                      : @"+995",
                              @"Germany"                                      : @"+49",
                              @"Ghana"                                        : @"+233",
                              @"Gibraltar"                                    : @"+350",
                              @"Greece"                                       : @"+30",
                              @"Greenland"                                    : @"+299",
                              @"Grenada"                                      : @"+1 473",
                              @"Guadeloupe"                                   : @"+590",
                              @"Guam"                                         : @"+1 671",
                              @"Guatemala"                                    : @"+502",
                              @"Guinea"                                       : @"+224",
                              @"Guinea-Bissau"                                : @"+245",
                              @"Guyana"                                       : @"+595",
                              @"Haiti"                                        : @"+509",
                              @"Honduras"                                     : @"+504",
                              @"Hong Kong SAR China"                          : @"+852",
                              @"Hungary"                                      : @"+36",
                              @"Iceland"                                      : @"+354",
                              @"India"                                        : @"+91",
                              @"Indonesia"                                    : @"+62",
                              @"Iran"                                         : @"+98",
                              @"Iraq"                                         : @"+964",
                              @"Ireland"                                      : @"+353",
                              @"Israel"                                       : @"+972",
                              @"Italy"                                        : @"+39",
                              @"Jamaica"                                      : @"+1 876",
                              @"Japan"                                        : @"+81",
                              @"Jordan"                                       : @"+962",
                              @"Kazakhstan"                                   : @"+7 7",
                              @"Kenya"                                        : @"+254",
                              @"Kiribati"                                     : @"+686",
                              @"North Korea"                                  : @"+850",
                              @"South Korea"                                  : @"+82",
                              @"Kuwait"                                       : @"+965",
                              @"Kyrgyzstan"                                   : @"+996",
                              @"Laos"                                         : @"+856",
                              @"Latvia"                                       : @"+371",
                              @"Lebanon"                                      : @"+961",
                              @"Lesotho"                                      : @"+266",
                              @"Liberia"                                      : @"+231",
                              @"Libya"                                        : @"+218",
                              @"Liechtenstein"                                : @"+423",
                              @"Lithuania"                                    : @"+370",
                              @"Luxembourg"                                   : @"+352",
                              @"Macau SAR China"                              : @"+853",
                              @"Macedonia"                                    : @"+389",
                              @"Madagascar"                                   : @"+261",
                              @"Malawi"                                       : @"+265",
                              @"Malaysia"                                     : @"+60",
                              @"Maldives"                                     : @"+960",
                              @"Mali"                                         : @"+223",
                              @"Malta"                                        : @"+356",
                              @"Marshall Islands"                             : @"+692",
                              @"Martinique"                                   : @"+596",
                              @"Mauritania"                                   : @"+222",
                              @"Mauritius"                                    : @"+230",
                              @"Mayotte"                                      : @"+262",
                              @"Mexico"                                       : @"+52",
                              @"Micronesia"                                   : @"+691",
                              @"Midway Island"                                : @"+1 808",
                              @"Micronesia"                                   : @"+691",
                              @"Moldova"                                      : @"+373",
                              @"Monaco"                                       : @"+377",
                              @"Mongolia"                                     : @"+976",
                              @"Montenegro"                                   : @"+382",
                              @"Montserrat"                                   : @"+1664",
                              @"Morocco"                                      : @"+212",
                              @"Myanmar"                                      : @"+95",
                              @"Namibia"                                      : @"+264",
                              @"Nauru"                                        : @"+674",
                              @"Nepal"                                        : @"+977",
                              @"Netherlands"                                  : @"+31",
                              @"Netherlands Antilles"                         : @"+599",
                              @"Nevis"                                        : @"+1 869",
                              @"New Caledonia"                                : @"+687",
                              @"New Zealand"                                  : @"+64",
                              @"Nicaragua"                                    : @"+505",
                              @"Niger"                                        : @"+227",
                              @"Nigeria"                                      : @"+234",
                              @"Niue"                                         : @"+683",
                              @"Norfolk Island"                               : @"+672",
                              @"Northern Mariana Islands"                     : @"+1 670",
                              @"Norway"                                       : @"+47",
                              @"Oman"                                         : @"+968",
                              @"Pakistan"                                     : @"+92",
                              @"Palau"                                        : @"+680",
                              @"Palestinian Territory"                        : @"+970",
                              @"Panama"                                       : @"+507",
                              @"Papua New Guinea"                             : @"+675",
                              @"Paraguay"                                     : @"+595",
                              @"Peru"                                         : @"+51",
                              @"Philippines"                                  : @"+63",
                              @"Poland"                                       : @"+48",
                              @"Portugal"                                     : @"+351",
                              @"Puerto Rico"                                  : @"+1 787",
                              @"Puerto Rico"                                  : @"+1 939",
                              @"Qatar"                                        : @"+974",
                              @"Reunion"                                      : @"+262",
                              @"Romania"                                      : @"+40",
                              @"Russia"                                       : @"+7",
                              @"Rwanda"                                       : @"+250",
                              @"Samoa"                                        : @"+685",
                              @"San Marino"                                   : @"+378",
                              @"Saudi Arabia"                                 : @"+966",
                              @"Senegal"                                      : @"+221",
                              @"Serbia"                                       : @"+381",
                              @"Seychelles"                                   : @"+248",
                              @"Sierra Leone"                                 : @"+232",
                              @"Singapore"                                    : @"+65",
                              @"Slovakia"                                     : @"+421",
                              @"Slovenia"                                     : @"+386",
                              @"Solomon Islands"                              : @"+677",
                              @"South Africa"                                 : @"+27",
                              @"South Georgia and the South Sandwich Islands" : @"+500",
                              @"Spain"                                        : @"+34",
                              @"Sri Lanka"                                    : @"+94",
                              @"Sudan"                                        : @"+249",
                              @"Suriname"                                     : @"+597",
                              @"Swaziland"                                    : @"+268",
                              @"Sweden"                                       : @"+46",
                              @"Switzerland"                                  : @"+41",
                              @"Syria"                                        : @"+963",
                              @"Taiwan"                                       : @"+886",
                              @"Tajikistan"                                   : @"+992",
                              @"Tanzania"                                     : @"+255",
                              @"Thailand"                                     : @"+66",
                              @"Timor Leste"                                  : @"+670",
                              @"Togo"                                         : @"+228",
                              @"Tokelau"                                      : @"+690",
                              @"Tonga"                                        : @"+676",
                              @"Trinidad and Tobago"                          : @"+1 868",
                              @"Tunisia"                                      : @"+216",
                              @"Turkey"                                       : @"+90",
                              @"Turkmenistan"                                 : @"+993",
                              @"Turks and Caicos Islands"                     : @"+1 649",
                              @"Tuvalu"                                       : @"+688",
                              @"Uganda"                                       : @"+256",
                              @"Ukraine"                                      : @"+380",
                              @"United Arab Emirates"                         : @"+971",
                              @"United Kingdom"                               : @"+44",
                              @"United States"                                : @"+1",
                              @"Uruguay"                                      : @"+598",
                              @"U.S. Virgin Islands"                          : @"+1 340",
                              @"Uzbekistan"                                   : @"+998",
                              @"Vanuatu"                                      : @"+678",
                              @"Venezuela"                                    : @"+58",
                              @"Vietnam"                                      : @"+84",
                              @"Wake Island"                                  : @"+1 808",
                              @"Wallis and Futuna"                            : @"+681",
                              @"Yemen"                                        : @"+967",
                              @"Zambia"                                       : @"+260",
                              @"Zanzibar"                                     : @"+255",
                              @"Zimbabwe"                                     : @"+263"
                              };
    //
    //    let countryDialingCode = prefixCodes[countryRegionCode]
    //    return countryDialingCode!
    
    
    NSString *countryDialingCode= [diction  objectForKey:countryRegionCode];
    
    
    return countryDialingCode;
}

@end
