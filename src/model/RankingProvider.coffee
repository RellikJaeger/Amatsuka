mongoose   = require 'mongoose'
BaseProvider = require './BaseProvider'
Schema     = mongoose.Schema
ObjectId   = Schema.ObjectId

RankingSchema = new Schema
  tweetIdStr:
   type: String
   index: true
  tweetStr:
   type: String
  retweetNum: 
    type: Number
  favNum: 
    type: Number
  totalNum: 
    type: Number
  postedBy:
    type: ObjectId
    ref: 'Illustrator'
    index: true
  updatedAt:
    type: Date
    default: Date.now()
  createdAt:
    type: Date
    default: Date.now()


mongoose.model 'Ranking', RankingSchema

RankingSchema.index year: -1

Ranking        = mongoose.model 'Ranking'

module.exports = class RankingProvider extends BaseProvider

  constructor: ->
    super(Ranking)

  findAll: (params) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Ranking findAll\n"
      console.log params
      Ranking.find {}
      .limit params.limit or 100
      .skip params.skip or 0
      .sort updatedAt: -1
      .exec (err, tweets) ->
        if err then return reject err
        return resolve tweets

  find: (params) ->
    return new Promise (resolve, reject) ->
      console.log "\n============> Ranking find\n"
      console.log params
      Ranking.find $and: params.condition
      .limit params.limit
      .skip params.skip
      .populate 'postedBy'
      .sort params.sort
      .exec (err, pictList) ->
        if err then return reject err
        return resolve pictList

  findOneAndUpdate: (params) ->
    return new Promise (resolve, reject) =>
      query = tweetIdStr: params.tweetIdStr
      data = params
      data.updatedAt = new Date()
      options = 'new': true, upsert: true
      return resolve super(query, data, options)
