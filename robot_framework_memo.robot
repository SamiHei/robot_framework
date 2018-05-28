*** Settings ***
Library     SeleniumLibrary
Library     DateTime
Library     OperatingSystem
Library     ImapLibrary
Library     String
Library     RequestsLibrary
Resource    ../../  # Goes two directory up in the
Resource    ${variable}/../ # Variables can be used in path
Resource    ../../exampleLib.robot

*** Variables ***
${EXAMPLE_PAGEOBJECT_1} =           xpath=//*[@id="root"]/div[2]/div/table
${EXAMPLE_PAGEOBJECT_2} =           id=exampleid
${EXAMPLE_PAGEOBJECT_3} =           # If xpath contains id which changes everytime take the xpath before the xpath which contains changing id and add for example /input

${PAGE_OBJECT_1} =                  xpath=
${PAGE_OBJECT_2} =                  id=
${PAGE_OBJECT_3} =                  id=
${PAGE_OBJECT_4} =                  xpath=
${PAGE_OBJECT_5} =                  id=

*** Keywords ***
Click
    [Documentation]  Usefull when testing with firefox (Click Element might not always work)
    [Arguments]    ${locator}
    Wait Until Element is Visible    ${locator}    ${WAIT_TIMEOUT}
    Mouse over  ${locator}
    Click Element    ${locator}

Email Handling Keyword
    [Documentation]  Keywords are taken from ImapLibrary
    [Arguments]  ${subject}  ${title1}  ${title2}
    Open Mailbox  host=  user=  password=
    ${LATEST} =  Wait For Email  sender=  status=UNSEEN  subject=${subject}  timeout=180
    ${body} =  Get Email Body  ${LATEST}
    ${body2} =  Decode Bytes To String  ${body}  UTF-8
    Should Contain  ${body2}  ${title1}
    Should Contain  ${body2}  ${title2}
    Delete Email  ${LATEST}
    Close Mailbox

Delete Emails Keyword
    [Documentation]  Deletes maximum of 5 latest emails from mailbox  (Can be modified by changing "IN RANGE max value")
    Open Mailbox  host=  user=  password=
    :FOR  ${i}  IN RANGE  0  5
    \   ${email} =  Run Keyword And Return Status  Wait For Email  sender=  timeout=1
    \   ${LATEST} =  Run Keyword If  '${email}'=='True'  Wait For Email  sender=  timeout=1
    \   Run Keyword If  '${email}'=='True'  Delete Email  ${LATEST}
    \   ...  ELSE  Exit For Loop
    Close Mailbox

For Loop Keyword
    [Arguments]  ${count}=${0}
    :FOR  ${i}  IN RANGE  0  5
    \  ${variable_1} =  Get List Items  ${PAGE_OBJECT_1}
    \  Run Keyword If  '${variable_1}'=='Item_${count}'  Click Element  ${PAGE_OBJECT_2}
    \  ${count} += 1
    \  ...  ELSE  Exit For Loop
    Click  ${PAGE_OBJECT_3}
    Log  ${variable_1}  # Logs to report what variable_1 contains

Element Contains Something Identifying
    [Arguments]  ${variable_2}=
    Click Element  ${PAGE_OBJECT_4}//div/div[3]/tr[td[div[contains(.,'${variable_2}')]]]//button

Click Element Which Contains Text
    [Arguments]  ${variable_3}=
    Click Element  ${PAGE_OBJECT_5}//div[2]/div[text()="${variable_3} "]

Scroll Page Down
    Execute Javascript  window.scrollTo(0, 400)

Select Browser In Test Suite
    Run Keyword If  '${BROWSER}'!='ie'  Open Browser    http://www.google.fi  ${BROWSER}
    ...  ELSE  Open Internet Explorer
    Maximize Browser Window

Get Variables From Environment Variables
    [Documentation]  ENVIRONMENTAL_VARIABLE_NAME can be for example the variable_4
    [Documentation]  Use Set Log Level NONE so if environmental variable contains password it is not printed to report
    [Documentation]  Set Log Level Info so the log level is returned for the rest of the tests
    Set Log Level  NONE

    ${variable_4} =  Get Environment Variable  ENVIRONMENTAL_VARIABLE_NAME  undefined
    Set Suite Variable  ${variable_4}  ${variable_4}

    Set Log Level  Info

*** Test Cases ***
Log In To Client
    exampleLib.Go To Login Page
    exampleLib.Input Username And Password
    exampleLib.Click Login
    exampleLib.Verify Login Worked
