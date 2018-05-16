class UpgradeJudgingTypesToNewRules < ActiveRecord::Migration[4.2]
  def up
    jt = JudgeType.find_by(name: "Presentation")
    if jt&.val_1_description == "Mistakes"
      jt.update(
        val_1_description: "Mistakes: Dismounts",
        val_2_description: "Choreography & Style",
        val_3_description: "Showmanship and Originality",
        val_4_description: "Interpretation",
        val_1_max: 10,
        val_2_max: 15,
        val_3_max: 15,
        val_4_max: 10
      )
      jt.save!
    end

    jt = JudgeType.find_by(name: "Technical")
    if jt&.val_1_description == "Variety & Originality of Skills"
      jt.update(
        val_1_description: "Quantity of Unicycling Skills & Transitions",
        val_2_description: "Mastery and Quality of Execution",
        val_3_description: "Difficulty and Duration",
        val_4_description: "N/A",
        val_1_max: 10,
        val_2_max: 15,
        val_3_max: 15,
        val_4_max: 0
      )
      jt.save!
    end
  end

  def down
    raise IrreversibleException
  end
end
