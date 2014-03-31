require! protractor

const URL = 'http://localhost:3333/'

describe 'app' (,) !->
  it 'should automatically redirect to /about when location hash/fragment is empty' !->
    browser.get URL
    url <-! browser.getCurrentUrl!.then
    expect url .toBe URL + 'about'

describe 'about page' (,) !->
  it 'should render github link' !->
    browser.get URL + 'about'
    expect element(by.className 'about-content').getText!
      .toMatch /github/
