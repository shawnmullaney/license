@isTest
public class ZendeskOrgDetailControllerTests {

    public class MockAPIResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setStatus('OK');
            if (req.getEndPoint().contains('related.json')) {
                res.setBody('{"organization_related":{"users_count":1,"tickets_count":4}}');
            } else if (req.getEndPoint().contains('users.json')) {
                res.setBody('{"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Bob Smith","email":"foo@bar.com","created_at":"2014-07-02T22:03:28Z","updated_at":"2014-07-02T22:03:28Z","time_zone":"Pacific Time (US & Canada)","phone":null,"photo":null,"locale_id":1,"locale":"en-US","organization_id":null,"role":"end-user","verified":false,"external_id":null,"tags":[],"alias":null,"active":true,"shared":false,"shared_agent":false,"last_login_at":null,"signature":null,"details":null,"notes":null,"custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false}],"next_page":null,"previous_page":null,"count":1}');
            } else if (req.getEndPoint().contains('tickets.json')) {
                res.setBody('{"tickets":[{"url":"https://test.zendesk.com/api/v2/tickets/123.json","id":123,"external_id":null,"via":{"channel":"web"},"created_at":"2014-03-02T19:53:45Z","updated_at":"2015-07-06T20:18:41Z","type":null,"subject":"test ticket","submitter_id":123,"assignee_id":123,"requester_id":123,"group_id":123,"ticket_form_id":58264,"brand_id":473434}],"users":[{"id":123,"url":"https://test.zendesk.com/api/v2/users/123.json","name":"Test User","email":"testuser@test.com","created_at":"2014-03-02T19:52:32Z","updated_at":"2015-07-20T23:57:27Z","time_zone":"Pacific Time (US & Canada)","phone":"111-222-2233","photo":null,"locale_id":1,"locale":"en-US","group_id":123,"organization_id":24973954,"role":"end-user","verified":false,"external_id":null,"tags":["canada"],"alias":"","active":true,"shared":false,"shared_agent":false,"last_login_at":null,"two_factor_auth_enabled":false,"signature":null,"details":"","notes":"","custom_role_id":null,"moderator":false,"ticket_restriction":"requested","only_private_comments":false,"restricted_agent":true,"suspended":false,"chat_only":false}],"groups":[{"url":"https://test.zendesk.com/api/v2/groups/123.json","id":123,"name":"Support","deleted":false,"created_at":"2014-03-02T16:35:15Z","updated_at":"2014-03-02T16:35:15Z"}],"next_page":null,"previous_page":null,"count":1}');
            } else if (req.getEndPoint().contains('organization')) {
                res.setBody('{"organization":{"url":"https://test.zendesk.com/api/v2/organizations/123.json","id":123,"name":"Zendesk","shared_tickets":false,"shared_comments":false,"external_id":null,"created_at":"2014-03-08T18:29:33Z","updated_at":"2014-03-08T18:29:33Z","domain_names":["zendesk.com"],"details":"","notes":"","group_id":123,"tags":["tag1","tag2"],"organization_fields":{"city":null,"customer":false,"customer_since":null,"employee_number":null,"street_address_1":null,"street_address_2":null,"website":null,"zip":null}}}');
            } else if (req.getEndPoint().contains('groups')) {
                res.setBody('{"group": { "url": "https://test.zendesk.com/api/v2/groups/123.json", "id": 123, "name": "Test", "deleted": false, "created_at": "2014-03-07T22:59:22Z", "updated_at": "2014-03-07T22:59:22Z"}}');
            } else {
                throw new ZendeskException('Unknown Mock Request');
            }
            return res;
        }
    }

    @testSetup static void setup() {
        Zendesk_API__c config = new Zendesk_API__c(Subdomain__c='s', Username__c='u', Password_or_Token__c='pwd', Authentication_Type__c='Password');
        insert config;
    }

    private @isTest static void testInit() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', '123');
        ZendeskOrgDetailController con = new ZendeskOrgDetailController();
        con.init();
        Test.stopTest();

        System.assertNotEquals(null, con.ui_org);
        System.assertNotEquals(null, con.ui_org.groupName);
        System.assertNotEquals(null, con.ui_org.domains);

        System.assertNotEquals(null, con.ui_tickets);
        System.assertNotEquals(0, con.ui_tickets.size());
        System.assertNotEquals(null, con.ui_tickets[0].requestedBy);
        System.assertNotEquals(null, con.ui_tickets[0].assignedTo);
        System.assertEquals('Support', con.ui_tickets[0].groupName);
    }

    private @isTest static void testTicketsPaging() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', '123');
        ZendeskOrgDetailController con = new ZendeskOrgDetailController();

        con.previous_tickets_page = 1;
        con.prevTicketPage();
        System.assertNotEquals(null, con.ui_tickets);
        System.assertNotEquals(0, con.ui_tickets.size());

        con.next_tickets_page = 2;
        con.nextTicketPage();
        System.assertNotEquals(null, con.ui_tickets);
        System.assertNotEquals(0, con.ui_tickets.size());

        Test.stopTest();
    }

    private @isTest static void testUsersPaging() {
        Test.setMock(HttpCalloutMock.class, new MockAPIResponse());

        Test.startTest();
        ApexPages.CurrentPage().getparameters().put('id', '123');
        ZendeskOrgDetailController con = new ZendeskOrgDetailController();

        con.previous_users_page = 1;
        con.prevUserPage();
        System.assertNotEquals(null, con.ui_users);
        System.assertNotEquals(0, con.ui_users.size());

        con.next_users_page = 2;
        con.nextUserPage();
        System.assertNotEquals(null, con.ui_users);
        System.assertNotEquals(0, con.ui_users.size());

        Test.stopTest();
    }
}
