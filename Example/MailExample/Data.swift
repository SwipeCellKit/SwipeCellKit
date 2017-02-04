//
//  Data.swift
//
//  Created by Jeremy Koch
//  Copyright © 2017 Jeremy Koch. All rights reserved.
//

import Foundation

class Email {
    let from: String
    let subject: String
    let body: String
    let date: Date
    var unread = false

    init(from: String, subject: String, body: String, date: Date) {
        self.from = from
        self.subject = subject
        self.body = body
        self.date = date
    }
    
    var relativeDateString: String {
        if Calendar.current.isDateInToday(date) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.doesRelativeDateFormatting = true
            return formatter.string(from: date)
        }
    }
}

extension Calendar {
    static func now(addingDays days: Int) -> Date {
        return Date().addingTimeInterval(Double(days) * 60 * 60 * 24)
    }
}

let mockEmails: [Email] = [
    Email(from: "Realm", subject: "Video: Operators and Strong Opinions with Erica Sadun", body: "Swift operators are flexible and powerful. They’re symbols that behave like functions, adopting a natural mathematical syntax, for example 1 + 2 versus add(1, 2). So why is it so important that you treat them like potential Swift Kryptonite? Erica Sadun discusses why your operators should be few, well-chosen, and heavily used. There’s even a fun interactive quiz! Play along with “Name That Operator!” and learn about an essential Swift best practice.", date: Calendar.now(addingDays: 0)),
    Email(from: "The Pragmatic Bookstore", subject: "[Pragmatic Bookstore] Your eBook 'Swift Style' is ready for download", body: "Hello, The gerbils at the Pragmatic Bookstore have just finished hand-crafting your eBook of Swift Style. It's available for download at the following URL:", date: Calendar.now(addingDays: 0)),
    Email(from: "Instagram", subject: "mrx, go live and send disappearing photos and videos", body: "Go Live and Send Disappearing Photos and Videos. We recently announced two updates: live video on Instagram Stories and disappearing photos and videos for groups and friends in Instagram Direct.", date: Calendar.now(addingDays: -1)),
    Email(from: "Smithsonian Magazine", subject: "Exclusive Sneak Peek Inside | Untold Stories of the Civil War", body: "For the very first time, the Smithsonian showcases the treasures of its Civil War collections in Smithsonian Civil War. This 384-page, hardcover book takes readers inside the museum storerooms and vaults to learn the untold stories behind the Smithsonian's most fascinating and significant pieces, including many previously unseen relics and artifacts. With over 500 photographs and text from forty-nine curators, the Civil War comes alive.", date: Calendar.now(addingDays: -2)),
    Email(from: "Apple News", subject: "How to Change Your Personality in 90 Days", body: "How to Change Your Personality. You are not stuck with yourself. New research shows that you can troubleshoot personality traits — in therapy.", date: Calendar.now(addingDays: -3)),
    Email(from: "Wordpress", subject: "New WordPress Site", body: "Your new WordPress site has been successfully set up at: http://example.com. You can log in to the administrator account with the following information:", date: Calendar.now(addingDays: -4)),
    Email(from: "IFTTT", subject: "See what’s new & notable on IFTTT", body: "See what’s new & notable on IFTTT. To disable these emails, sign in to manage your settings or unsubscribe.", date: Calendar.now(addingDays: -5)),
    Email(from: "Westin Vacations", subject: "Your Westin exclusive expires January 11", body: "Last chance to book a captivating 5-day, 4-night vacation in Rancho Mirage for just $389. Learn more. No images? CLICK HERE", date: Calendar.now(addingDays: -6)),
    Email(from: "Nugget Markets", subject: "Nugget Markets Weekly Specials Starting February 15, 2017", body: "Scan & Save. For this week’s Secret Special, let’s “brioche” the subject of breakfast. This Friday and Saturday, February 24–25, buy one loaf of Euro Classic Brioche and get one free! This light, soft, hand-braided buttery brioche loaf from France is perfect for an authentic French toast feast. Make Christmas morning extra special with our Signature Recipe for Crème Brûlée French Toast Soufflé!", date: Calendar.now(addingDays: -7)),
    Email(from: "GeekDesk", subject: "We have some exciting things happening at GeekDesk!", body: "Wouldn't everyone be so much happier if we all owned GeekDesks?", date: Calendar.now(addingDays: -8))
]

