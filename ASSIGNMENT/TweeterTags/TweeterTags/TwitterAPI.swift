//
//  TwitterAPI.swift
//

import Foundation
import Accounts
import Social
import CoreLocation

// MARK: - Twitter Tweet
// IndexedKeywords are substrings of the Tweet's text e.g.g hashtag, user, url
public class Tweet : CustomStringConvertible
{
    public var text: String
    public var user: User
    public var created: NSDate
    public var id: String?
    public var media = [MediaItem]()
    public var mediaMentions = [IndexedKeyword]()
    public var hashtags = [IndexedKeyword]()
    public var urls = [IndexedKeyword]()
    public var userMentions = [IndexedKeyword]()
    public var description: String {
        return "\(user) - \(created)\n\(text)\nhashtags: \(hashtags)\nurls: \(urls)\nuser_mentions: \(userMentions)" + (id == nil ? "" : "\nid: \(id!)")
    }

    
    public struct IndexedKeyword: CustomStringConvertible
    {
        public var keyword: String = ""         // will include # or @ or http:// prefix
        public var range: Range<String.Index>   // index into the Tweet's text property only
        public var nsrange = NSMakeRange(0, 0)  // index into an NS[Attributed]String made from the Tweet's text
        public var description: String {
            get { return "\(keyword) (\(nsrange.location), \(nsrange.location+nsrange.length-1))" }
        }

        public init?(data: NSDictionary?, inText: String, prefix: String?) {
            guard let indices = data?.valueForKeyPath(TwitterAPIKey.Entities.Indices) as? NSArray,
                startIndex = (indices.firstObject as? NSNumber)?.integerValue,
                endIndex = (indices.lastObject as? NSNumber)?.integerValue else {
                return nil
            }
            
            range = inText.rangeOfString(inText)!
            let length = inText.characters.count
            if length > 0 {
                let start = max(min(startIndex, length-1), 0)
                let end = max(min(endIndex, length), 0)
                if end > start {
                    range = inText.startIndex.advancedBy(start)...inText.startIndex.advancedBy(end-1)
                    keyword = inText.substringWithRange(range)
                    if prefix != nil && !keyword.hasPrefix(prefix!) && start > 0 {
                        range = inText.startIndex.advancedBy(start-1)...inText.startIndex.advancedBy(end-2)
                        keyword = inText.substringWithRange(range)
                    }
                    if prefix == nil || keyword.hasPrefix(prefix!) {
                        nsrange = inText.rangeOfString(keyword, nearRange: NSMakeRange(startIndex, endIndex-startIndex))
                        if nsrange.location != NSNotFound {
                            return
                        }
                    }
                }
            }
        }
    }

    // MARK: Private
    init?(data: NSDictionary?) {
        guard let user = User(data: data?.valueForKeyPath(TwitterAPIKey.User) as? NSDictionary), text = data?.valueForKeyPath(TwitterAPIKey.Text) as? String, created = (data?.valueForKeyPath(TwitterAPIKey.Created) as? String)?.asTwitterDate
            else {
                self.text = ""
                self.user = User()
                self.created = NSDate()
                return nil
        }
        
        self.user = user
        self.text = text
        self.created = created
        id = data?.valueForKeyPath(TwitterAPIKey.ID) as? String
        if let mediaEntities = data?.valueForKeyPath(TwitterAPIKey.Media) as? NSArray {
            for mediaData in mediaEntities {
                if let mediaItem = MediaItem(data: mediaData as? NSDictionary) {
                    media.append(mediaItem)
                }
            }
            mediaMentions = getIndexedKeywords(mediaEntities, inText: text, prefix: "h")
        }
        let hashtagMentionsArray = data?.valueForKeyPath(TwitterAPIKey.Entities.Hashtags) as? NSArray
        hashtags = getIndexedKeywords(hashtagMentionsArray, inText: text, prefix: "#")
        let urlMentionsArray = data?.valueForKeyPath(TwitterAPIKey.Entities.URLs) as? NSArray
        urls = getIndexedKeywords(urlMentionsArray, inText: text, prefix: "h")
        let userMentionsArray = data?.valueForKeyPath(TwitterAPIKey.Entities.UserMentions) as? NSArray
        userMentions = getIndexedKeywords(userMentionsArray, inText: text, prefix: "@")
    }
    
    private func getIndexedKeywords(dictionary: NSArray?, inText: String, prefix: String? = nil) -> [IndexedKeyword] {
        var results = [IndexedKeyword]()
        if let indexedKeywords = dictionary {
            for indexedKeywordData in indexedKeywords {
                if let indexedKeyword = IndexedKeyword(data: indexedKeywordData as? NSDictionary, inText: inText, prefix: prefix) {
                    results.append(indexedKeyword)
                }
            }
        }
        return results
    }
}

// MARK: - Twitter User
public struct User: CustomStringConvertible
{
    public var screenName: String! = nil
    public var name: String! = nil
    public var profileImageURL: NSURL? = nil
    public var verified: Bool = false
    public var id: String!
    public var description: String {
        let v = verified ? " ✅" : "";
        return "@\(screenName) (\(name))\(v)"
    }
    
    // MARK: Private
    init?(data: NSDictionary?) {
        guard let name = data?.valueForKeyPath(TwitterAPIKey.Name) as? String,
            screenName = data?.valueForKeyPath(TwitterAPIKey.ScreenName) as? String else {
            return nil
        }
        self.name = name
        self.screenName = screenName
        self.id = data?.valueForKeyPath(TwitterAPIKey.ID) as? String
        if let verified = data?.valueForKeyPath(TwitterAPIKey.Verified)?.boolValue {
            self.verified = verified
        }
        if let urlString = data?.valueForKeyPath(TwitterAPIKey.ProfileImageURL) as? String {
            self.profileImageURL = NSURL(string: urlString)
        }
    }
    
    var asPropertyList: AnyObject {
        let plistDict: [String: String] = [
            TwitterAPIKey.Name: name,
            TwitterAPIKey.ScreenName: screenName,
            TwitterAPIKey.ID: id,
            TwitterAPIKey.Verified: verified ? "YES" : "NO",
            TwitterAPIKey.ProfileImageURL: profileImageURL?.absoluteString ?? ""]
        return plistDict
    }
    
    
    init() {
        screenName = "Unknown"
        name = "Unknown"
    }
}

// MARK: - Twitter Media Item
public struct MediaItem: CustomStringConvertible
{
    public let url: NSURL!
    public var aspectRatio: Double = 0.0
    public var description: String {
        return (url.absoluteString ?? "no url") + " (aspect ratio = \(aspectRatio))"
    }
    
    // MARK: Private
    init?(data: NSDictionary?) {
        guard let urlString = data?.valueForKeyPath(TwitterAPIKey.MediaURL) as? NSString, url = NSURL(string: urlString as String), h = data?.valueForKeyPath(TwitterAPIKey.Height) as? NSNumber, w = data?.valueForKeyPath(TwitterAPIKey.Width) as? NSNumber where h.doubleValue != 0
        else {
                return nil
        }
        
        self.url = url
        self.aspectRatio = w.doubleValue / h.doubleValue
    }
}

private var twitterAccount: ACAccount?

// MARK: - Twitter Request
// Set  requestType and parametersa and call fetch (or fetchTweets)
// Refresh request with requestFor{Newer, Older}
public class TwitterRequest
{
    public var requestType: String
    public var parameters = Dictionary<String, String>()
    
    // designated initializer
    public init(_ requestType: String, _ parameters: Dictionary<String, String> = [:]) {
        self.requestType = requestType
        self.parameters = parameters
    }
    
    // convenience initializer for creating a TwitterRequest that is a search for Tweets
    public convenience init(search: String, count: Int = 0, _ resultType: SearchResultType = .Mixed, _ region: CLCircularRegion? = nil) {
        var parameters = [TwitterAPIKey.Query : search]
        if count > 0 {
            parameters[TwitterAPIKey.Count] = "\(count)"
        }
        switch resultType {
        case .Recent: parameters[TwitterAPIKey.ResultType] = TwitterAPIKey.ResultTypeRecent
        case .Popular: parameters[TwitterAPIKey.ResultType] = TwitterAPIKey.ResultTypePopular
        default: break
        }
        if let geocode = region {
            parameters[TwitterAPIKey.Geocode] = "\(geocode.center.latitude),\(geocode.center.longitude),\(geocode.radius/1000.0)km"
        }
        self.init(TwitterAPIKey.SearchForTweets, parameters)
    }
    
    public enum SearchResultType {
        case Mixed
        case Recent
        case Popular
    }
    
    // convenience "fetch" for when self is a request that returns Tweet(s)
    // handler is not necessarily invoked on the main queue
    public func fetchTweets(handler: ([Tweet]) -> Void) {
        fetch { results in
            var tweets = [Tweet]()
            var tweetArray: NSArray?
            if let dictionary = results as? NSDictionary {
                if let tweets = dictionary[TwitterAPIKey.Tweets] as? NSArray {
                    tweetArray = tweets
                } else if let tweet = Tweet(data: dictionary) {
                    tweets = [tweet]
                }
            } else if let array = results as? NSArray {
                tweetArray = array
            }
            if tweetArray != nil {
                for tweetData in tweetArray! {
                    if let tweet = Tweet(data: tweetData as? NSDictionary) {
                        tweets.append(tweet)
                    }
                }
            }
            handler(tweets)
        }
    }
    
    public typealias PropertyList = AnyObject
    
    // send an arbitrary request off to Twitter
    // calls the handler (not necessarily on the main queue) with the JSON results converted to a Property List
    public func fetch(handler: (results: PropertyList?) -> Void) {
        performTwitterRequest(SLRequestMethod.GET, handler: handler)
    }
    
    // generates a request for older Tweets than were returned by self
    // only makes sense if self has done a fetch already
    // only makes sense for requests for Tweets
    public var requestForOlder: TwitterRequest? {
        return min_id != nil ? modifiedRequest(parametersToChange: [TwitterAPIKey.MaxID : min_id!]) : nil
    }
    
    // generates a request for newer Tweets than were returned by self
    // only makes sense if self has done a fetch already
    // only makes sense for requests for Tweets
    public var requestForNewer: TwitterRequest? {
        return (max_id != nil) ? modifiedRequest(parametersToChange: [TwitterAPIKey.SinceID : max_id!], clearCount: true) : nil
    }
    
    // MARK: - Private
    // creates an appropriate SLRequest using the specified SLRequestMethod
    // then calls the other version of this method that takes an SLRequest
    // handler is not necessarily called on the main queue
    func performTwitterRequest(method: SLRequestMethod, handler: (PropertyList?) -> Void) {
        let jsonExtension = (self.requestType.rangeOfString(JSONExtension) == nil) ? JSONExtension : ""
        let request = SLRequest(
            forServiceType: SLServiceTypeTwitter,
            requestMethod: method,
            URL: NSURL(string: "\(TwitterURLPrefix)\(self.requestType)\(jsonExtension)"),
            parameters: self.parameters
        )
        performTwitterRequest(request, handler: handler)
    }
    
    // sends the request to Twitter
    // unpackages the JSON response into a Property List
    // and calls handler (not necessarily on the main queue)
    func performTwitterRequest(request: SLRequest, handler: (PropertyList?) -> Void) {
        if let account = twitterAccount {
            request.account = account
            request.performRequestWithHandler { (jsonResponse, httpResponse, _) in
                var propertyListResponse: PropertyList?
                if jsonResponse != nil {
                    propertyListResponse = try? NSJSONSerialization.JSONObjectWithData(
                        jsonResponse,
                        options: NSJSONReadingOptions.MutableLeaves)
                    if propertyListResponse == nil {
                        let error = "Couldn't parse JSON response."
                        self.log(error)
                        propertyListResponse = error
                    }
                } else {
                    let error = "No response from Twitter."
                    self.log(error)
                    propertyListResponse = error
                }
                self.synchronize {
                    self.captureFollowonRequestInfo(propertyListResponse)
                }
                handler(propertyListResponse)
            }
        } else {
            let accountStore = ACAccountStore()
            let twitterAccountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
            accountStore.requestAccessToAccountsWithType(twitterAccountType, options: nil) { (granted, _) in
                if granted {
                    if let account = accountStore.accountsWithAccountType(twitterAccountType)?.last as? ACAccount {
                        twitterAccount = account
                        self.performTwitterRequest(request, handler: handler)
                    } else {
                        let error = "Unable to discover Twitter account. Check iOS Settings"
                        self.log(error)
                        handler(error)
                    }
                } else {
                    let error = "Access to Twitter was not granted."
                    self.log(error)
                    handler(error)
                }
            }
        }
    }
    
    private var min_id: String? = nil
    private var max_id: String? = nil
    
    // modifies parameters in an existing request to create a new one
    private func modifiedRequest(parametersToChange parametersToChange: Dictionary<String,String>, clearCount: Bool = false) -> TwitterRequest {
        var newParameters = parameters
        for (key, value) in parametersToChange {
            newParameters[key] = value
        }
        if clearCount { newParameters[TwitterAPIKey.Count] = nil }
        return TwitterRequest(requestType, newParameters)
    }
    
    // captures the min_id and max_id information
    // to support requestForNewer and requestForOlder
    private func captureFollowonRequestInfo(propertyListResponse: PropertyList?) {
        if let responseDictionary = propertyListResponse as? NSDictionary {
            self.max_id = responseDictionary.valueForKeyPath(TwitterAPIKey.SearchMetadata.MaxID) as? String
            if let next_results = responseDictionary.valueForKeyPath(TwitterAPIKey.SearchMetadata.NextResults) as? String {
                for queryTerm in next_results.componentsSeparatedByString(TwitterAPIKey.SearchMetadata.Separator) {
                    if queryTerm.hasPrefix("?\(TwitterAPIKey.MaxID)=") {
                        let next_id = queryTerm.componentsSeparatedByString("=")
                        if next_id.count == 2 {
                            self.min_id = next_id[1]
                        }
                    }
                }
            }
        }
    }
    
    // debug println with identifying prefix
    private func log(whatToLog: AnyObject) {
        debugPrint("TwitterRequest: \(whatToLog)")
    }
    
    // synchronizes access to self across multiple threads
    private func synchronize(closure: () -> Void) {
        objc_sync_enter(self)
        closure()
        objc_sync_exit(self)
    }
    
    // constants
    let JSONExtension = ".json"
    let TwitterURLPrefix = "https://api.twitter.com/1.1/"
}



// MARK: - NSString private extension
private extension NSString {
    func rangeOfString(substring: NSString, nearRange: NSRange) -> NSRange {
        var start = max(min(nearRange.location, length - 1), 0)
        var end = max(min(nearRange.location + nearRange.length, length), 0)
        var done = false
        while !done {
            let range = rangeOfString(substring as String, options: NSStringCompareOptions(), range: NSMakeRange(start, end-start))
            if range.location != NSNotFound {
                return range
            }
            done = true
            if start > 0 { start-- ; done = false }
            if end < length { end++ ; done = false }
        }
        return NSMakeRange(NSNotFound, 0)
    }

    var asTwitterDate: NSDate? {
        get {
            let dateFormatter = NSDateFormatter()
            dateFormatter.locale = NSLocale(localeIdentifier: "en_US")
            dateFormatter.dateFormat = "EEE MMM dd HH:mm:ss Z yyyy"
            return dateFormatter.dateFromString(self as String)
        }
    }
}

// MARK: - Tweeter API keys
private struct TwitterAPIKey {
    // Tweeter tweet
    static let Name = "name"
    static let ScreenName = "screen_name"
    static let User = "user"
    static let Text = "text"
    static let Created = "created_at"
    static let ID = "id_str"
    static let Verified = "verified"
    static let ProfileImageURL = "profile_image_url"
    static let Media = "entities.media"
    
    struct Entities {
        static let Hashtags = "entities.hashtags"
        static let URLs = "entities.urls"
        static let UserMentions = "entities.user_mentions"
        static let Indices = "indices"
    }
    
    // Tweeter media
    static let MediaURL = "media_url_https"
    static let Width = "sizes.small.w"
    static let Height = "sizes.small.h"
    
    // Tweeter requests
    static let Count = "count"
    static let Query = "q"
    static let Tweets = "statuses"
    static let ResultType = "result_type"
    static let ResultTypeRecent = "recent"
    static let ResultTypePopular = "popular"
    static let Geocode = "geocode"
    static let SearchForTweets = "search/tweets"
    static let MaxID = "max_id"
    static let SinceID = "since_id"
    
    struct SearchMetadata {
        static let MaxID = "search_metadata.max_id_str"
        static let NextResults = "search_metadata.next_results"
        static let Separator = "&"
    }
}



