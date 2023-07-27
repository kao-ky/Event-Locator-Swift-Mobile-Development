//
//  EventListRowView.swift
//  EventLocator
//
//  Created by Kao on 2023-07-05.
//

import SwiftUI

struct EventListRowView: View {
    let event: Event
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            AsyncImage(url: URL(string: event.performers[0].image),
                       content: {
                            $0.resizable()
                                .aspectRatio(contentMode: .fit)
                       },
                       placeholder: {
                           Image(systemName: "photo")
                       })
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            Text(event.title)
                .font(.headline)
            
            HStack {
                Text(
                    event.dateTimeLocal.date.formatted(
                        .dateTime
//                            .weekday()
                            .day()
                            .month()
                            .hour()
                            .minute()
                    )
                )
                Spacer()
                Text("\(event.venue.city), \(event.venue.country)")
            }
            .font(.subheadline)
        }
        .padding(.vertical, 5)
    }
}

//struct EventListRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        let event = Event()                 // requires initialisation for preview
//        EventListRowView(event: Event)
//    }
//}
