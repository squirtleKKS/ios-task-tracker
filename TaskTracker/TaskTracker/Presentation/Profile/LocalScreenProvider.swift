import Foundation

final class LocalScreenProvider: BackendDrivenScreenLoading {
    func loadScreen(configuration: BackendDrivenScreenConfiguration) async throws -> BDUIScreen {
        let json = """
        {
          "root": {
            "type": "container",
            "props": {
              "cardStyle": false
            },
            "layout": {
              "padding": {
                "top": "xl",
                "left": "l",
                "bottom": "xl",
                "right": "l"
              },
              "backgroundColor": "background"
            },
            "subviews": [
              {
                "type": "stack",
                "props": {
                  "axis": "vertical",
                  "spacing": "l",
                  "alignment": "fill",
                  "distribution": "fill"
                },
                "subviews": [
                  {
                    "type": "label",
                    "props": {
                      "text": "Профиль",
                      "style": "title",
                      "textAlignment": "center",
                      "numberOfLines": 0
                    },
                    "subviews": []
                  },
                  {
                    "type": "message",
                    "props": {
                      "style": "empty",
                      "title": "Пользователь",
                      "message": "test",
                      "actionTitle": null
                    },
                    "subviews": []
                  },
                  {
                    "type": "textField",
                    "props": {
                      "title": "Email",
                      "placeholder": "Введите email",
                      "text": "test@gmail.com",
                      "isSecure": false
                    },
                    "subviews": []
                  },
                  {
                    "type": "button",
                    "props": {
                      "title": "Редактировать профиль",
                      "style": "primary",
                      "action": {
                        "type": "print",
                        "payload": {
                          "message": "Edit profile tapped"
                        }
                      }
                    },
                    "subviews": []
                  },
                  {
                    "type": "button",
                    "props": {
                      "title": "Назад",
                      "style": "secondary",
                      "action": {
                        "type": "route",
                        "payload": {
                          "destination": "back"
                        }
                      }
                    },
                    "subviews": []
                  }
                ]
              }
            ]
          }
        }
        """

        let data = Data(json.utf8)
        return try JSONDecoder().decode(BDUIScreen.self, from: data)
    }
}
