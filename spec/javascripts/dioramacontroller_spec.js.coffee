describe("diorama controller", ()->
  controller = undefined
  
  beforeEach( () ->
    controller = new DioramaController()
  )
  
  it("should be able to play a Song", () ->
    player.play(song)
    expect(player.currentlyPlayingSong).toEqual(song)

    # demonstrates use of custom matcher
    expect(player).toBePlaying(song)
  )
)