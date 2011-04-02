//
//  BringBanksLoader.m
//  BringBanks
//
//  Created by Robert Mooney on 02/04/2011.
//  Copyright 2011 Robert Mooney. All rights reserved.
//

#import "BringBanksLoader.h"
#import "BringBank.h"
#import <libxml/xmlreader.h>

#define REMOTE_URL_KEY @"remoteURL"
#define LOCAL_URL_KEY @"localURL"
#define LAST_MODIFIED_KEY @"Last-Modified"
#define ETAG_KEY @"Etag"

@interface BringBanksLoader ()

- (void)loadBringBanksFromData_:(NSData *)data;

@end

@implementation BringBanksLoader

@synthesize delegate;

- (void)dealloc {
    [configFileURL_ release];
    [remoteFileURL_ release];
    [localFileURL_ release];
    [receivedData_ release];
    [lastModified_ release];
    [etag_ release];
    [super dealloc];
}

- (id)initWithConfigFileURL:(NSURL *)configFileURL {
    self = [super init];
    if (self) {
        configFileURL_ = [configFileURL retain];
        
        NSDictionary *configDictionary = [NSDictionary dictionaryWithContentsOfURL:configFileURL];
        
        remoteFileURL_ = [[NSURL alloc] initWithString:[configDictionary objectForKey:REMOTE_URL_KEY]];
        localFileURL_ = [[[configFileURL URLByDeletingLastPathComponent] URLByAppendingPathComponent:[configDictionary objectForKey:LOCAL_URL_KEY]] retain];
        lastModified_ = [[configDictionary objectForKey:LAST_MODIFIED_KEY] retain];
        etag_ = [[configDictionary objectForKey:ETAG_KEY] retain];

    }
    return self;
}

- (void)start {
    
    if ([self.delegate respondsToSelector:@selector(bringBanksLoaderDidStart:)]) {
        [self.delegate bringBanksLoaderDidStart:self];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:remoteFileURL_];
        
    [request addValue:lastModified_ forHTTPHeaderField:@"If-Modified-Since"];
    [request addValue:etag_ forHTTPHeaderField:@"If-None-Match"];    
    
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    [request release];
    
    if (connection) {
        receivedData_ = [[NSMutableData data] retain];
    } else {        
        [self loadBringBanksFromData_:[NSData dataWithContentsOfURL:localFileURL_]];
    }

}

#pragma mark - URL connection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *HTTPResponse = (NSHTTPURLResponse *)response;
    
    if ([HTTPResponse statusCode] == 304) {
        // we have the latest version already
        [connection cancel];
        [connection release];
        [receivedData_ release];        
        receivedData_ = nil;
        
        [self loadBringBanksFromData_:[NSData dataWithContentsOfURL:localFileURL_]];
        
    } else {
        
        [lastModified_ release];
        [etag_ release];
        
        lastModified_ = [[[HTTPResponse allHeaderFields] objectForKey:LAST_MODIFIED_KEY] retain];
        etag_ = [[[HTTPResponse allHeaderFields] objectForKey:ETAG_KEY] retain];
        
        if ([self.delegate respondsToSelector:@selector(bringBanksLoaderDidStartUpdate:)]) {
            [self.delegate bringBanksLoaderDidStartUpdate:self];
        }
        [receivedData_ setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [receivedData_ appendData:data];
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error {
    [connection release];
    [receivedData_ release];
    receivedData_ = nil;
    
    [self loadBringBanksFromData_:[NSData dataWithContentsOfURL:localFileURL_]];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [receivedData_ writeToURL:localFileURL_ atomically:YES];
    
    NSDictionary *newRemoteConfig = [NSDictionary dictionaryWithObjectsAndKeys:[remoteFileURL_ absoluteString], REMOTE_URL_KEY,
                                     [localFileURL_ lastPathComponent], LOCAL_URL_KEY,
                                     lastModified_, LAST_MODIFIED_KEY,
                                     etag_, ETAG_KEY, nil];
    
    [newRemoteConfig writeToURL:configFileURL_ atomically:YES];
    
    [self loadBringBanksFromData_:receivedData_];
    
    // release the connection, and the data object
    [connection release];
    [receivedData_ release];    
    receivedData_ = nil;
}

- (void)loadBringBanksFromData_:(NSData *)data {
    
    NSMutableArray *bringBanks = [[NSMutableArray alloc] initWithCapacity:0];
    
    BringBank *bringBank = nil;    
    CLLocationCoordinate2D coord;
    
    xmlTextReaderPtr reader = xmlReaderForMemory(
                                                 [data bytes], 
                                                 [data length], 
                                                 NULL, 
                                                 NULL, 
                                                 (XML_PARSE_NOBLANKS | XML_PARSE_NOCDATA | XML_PARSE_NOERROR | XML_PARSE_NOWARNING)
                                                 );
	
	if (reader) {
		
		xmlChar const *currentTagName = NULL;
		xmlChar const *currentTagValue = NULL;
		xmlChar *currentNameAttr = NULL;
		
		while (YES) {
			if (!xmlTextReaderRead(reader)) {
				break;
			}
			
			switch (xmlTextReaderNodeType(reader)) {
					
				case XML_READER_TYPE_ELEMENT:		
                    
					currentTagName = xmlTextReaderConstName(reader);
					
					if (xmlStrEqual(currentTagName, BAD_CAST "Placemark")) {
						bringBank = [[BringBank alloc] init];
					}
					
					if (xmlStrEqual(currentTagName, BAD_CAST "SimpleData")) {
						currentNameAttr = xmlTextReaderGetAttribute(reader, BAD_CAST "name");
					}
					continue;
					
				case XML_READER_TYPE_END_ELEMENT:		
                    
					currentTagName = xmlTextReaderConstName(reader);
					
					if (xmlStrEqual(currentTagName, BAD_CAST "Placemark")) {
                        bringBank.coordinate = coord;
                        [bringBanks addObject:bringBank];
                        [bringBank release];
                        bringBank = nil;
                    }
					
					if (currentNameAttr != NULL) {						
						xmlFree(currentNameAttr);
						currentNameAttr = NULL;
					}
					
					continue;
					
				case XML_READER_TYPE_TEXT:
					
					if (xmlStrEqual(currentTagName, BAD_CAST "SimpleData")) {	
						
						currentTagValue = xmlTextReaderConstValue(reader);
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "ID_")) {                            
                            bringBank.ID = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "WEIGHT")) {                            
                            bringBank.weight = atof((const char *)currentTagValue);
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "GIS_ID")) {                            
                            bringBank.GISID = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "ELECTORAL_Area")) {                            
                            bringBank.electoralArea = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        } 
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "LOCATION")) {                            
                            bringBank.location = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        } 
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "AREA")) {                            
                            bringBank.area = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "GLASS_OPER")) {                            
                            bringBank.operatorName = [NSString stringWithUTF8String:(const char *)currentTagValue];
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "GLASS")) {
                            if (xmlStrEqual(currentTagValue, BAD_CAST "Y")) {
								bringBank.materialTypes += BringBankMaterialTypeGlass;
                            }
                        }    
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "CANS")) {
                            if (xmlStrEqual(currentTagValue, BAD_CAST "Y")) {
								bringBank.materialTypes += BringBankMaterialTypeCans;
                            }
                        }   
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "TEXTILE")) {
                            if (xmlStrEqual(currentTagValue, BAD_CAST "Y")) {
								bringBank.materialTypes += BringBankMaterialTypeTextiles;
                            }
                        }
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "LAT")) {
                            coord.latitude = atof((const char *)currentTagValue);
                        }                        
                        
                        if (xmlStrEqual(currentNameAttr, BAD_CAST "LONG")) {
                            coord.longitude = atof((const char *)currentTagValue);
                        }
                        
					}
					
					continue;					
			}
		}
	}		
	xmlTextReaderClose(reader);
    xmlFreeTextReader(reader);
        
    if ([self.delegate respondsToSelector:@selector(bringBanksLoader:didLoadBringBanks:)]) {
        [self.delegate bringBanksLoader:self didLoadBringBanks:[[bringBanks copy] autorelease]];
    }
    
    [bringBanks release];
}

@end
